pragma solidity ^0.4.24;


// contract BattleshipFactory {
//     address[] public deployedBattleships;

//     function createBattleship() public { 
        // address newBattleship = new Battleship();
        // deployedBattleships.push(newBattleship);
        // Battleship battleship = new Battleship();
//     }

//     function getDeployedBattleships() public view returns (address[]) {
//         return deployedBattleships;
//     }
// }

contract Battleship {

    // ================================================================================
    // GLOBAL VARIABLES
    // ================================================================================
    address public owner;
    address[] public players;
    address public player1;
    address public player2;
    mapping (address => uint) public balances;

    int[] internal p1Board;
    int[] internal p2Board;

    uint public gameId;
    // uint public minimumBet;

    uint[] public p1Hits;
    mapping(uint => bool) public p1Misses;
    
    uint[] public p2Hits;
    mapping(uint => bool) public p2Misses;
    
    uint[] public p1LogOfGuesses;
    uint public p1Position;

    uint[] public p2LogOfGuesses;
    uint public p2Position;
    
    uint public p1SuccessfulGuesses;
    uint public p2SuccessfulGuesses;

    address public badActor1;
    address public badActor2;
    
    address public forfeit1;
    address public forfeit2;

    mapping(uint => Turn) turns;
    int public turnCount;      // decided to increment turnCount rather than
                                // use `Turns[] public turns;` with State, i.e.,
                                // create a State `nextTurn` and then
                                // step through sequential turns with (a) functions,
                                // e.g., `function turnOne() {}`, `function
                                // turnTwo() {}` or (b) a for loop - whose
                                // gas cost increases linearly with the number
                                // of iterations
    
    struct Turn {
        uint gameId;
        uint guess;
        uint result;
        Stages stage;
        mapping(uint => bool) p1Hits;
        mapping(uint => bool) p1Misses;
        mapping(uint => bool) p2Hits;
        mapping(uint => bool) p2Misses;
    }
    
    // ================================================================================
    // MODIFIERS
    // ================================================================================

    modifier restricted() {
        require(msg.sender == owner);
        _;
    }

    modifier onlyOwner() {
        assert(owner == msg.sender);
        _;
    }

    // ================================================================================
    // STATE 
    // ================================================================================
    enum Stages { 
        startOfGame,           // @dev start game
        acceptTheChallenge,    // @dev begin play
        takeYourTurnAttacking, // @dev take turns attacking
        gameIsOver,            // @dev end of play
        declareTheWinner       // @dev declare winner and payout
    }
    
    // This is the current stage.
    Stages public stage = Stages.startOfGame;

    uint public startTurn = now;

    modifier atStage(Stages _stage) {
        require(stage == _stage);
        _;
    }
    
    // @param This modifier goes to the next stage after the function is done.
    modifier transitionNext()
    {
        _;
        nextStage();
    }
    
    function nextStage() internal {
        stage = Stages(uint(stage) + 1);
    }
   
    modifier timedTransitions() {
        if (stage == Stages.takeYourTurnAttacking && now >= now + 2 minutes) {
            nextStage();
        }
        // The other stages transition by transaction
        _;
    }

    // ================================================================================
    // EVENTS
    // ================================================================================
    event StartOfGame(uint gameId);
    event AcceptTheChallenge(uint gameId);
    event TakeYourTurnAttacking(uint gameId);
    event GameIsOver(uint gameId);
    event DeclareTheWinner(uint gameId);
    
    // ================================================================================
    // GAME 
    // ================================================================================

    // @title Constructor 
    constructor() public {
        // @dev constructor function. 
        // @param  owner       Sets contract owner
        // @param  turnCount   Sets the initial turnCount to 0
        // @param  minimumBet  Not implemented; contract currently requires an entrance fee of 5 ether.
        //                     I.e., a bet is not a varaible amount established by the Player1
        owner = msg.sender;
        turnCount = 0;
        // minimumBet = minimum;
    }
    
    // @title Is A Valid Number
    function isValidNumber(uint _guess) private pure returns (bool) {
        // @dev    Range of valid ship positions; corresponds to cells in a table aka game board
        // @param  _guess Expected table cell / game board position of a ship
        // @return Bool, in or outside of range
        return _guess >= 1 && _guess <= 100;
    }
    
    // @title Get Length P1
    function getLengthP1() public constant returns(uint length) {
        // @dev    An array of Player1's successive guesses. A guess is the expected game board position of a ship
        // @param  p1LogOfGuesses Array
        // @return length         Length of the array, i.e., the number of guesses that Player1 has submitted
        return p1LogOfGuesses.length;
    }
    
    // @title Get Length P2
    function getLengthP2() public constant returns(uint length) {
        // @dev    An array of Player2's successive guesses. A guess is the expected game board position of a ship
        // @param  p1LogOfGuesses Array
        // @return length         Length of the array, i.e., the number of guesses that Player2 has submitted
        return p2LogOfGuesses.length;
    }
    
    // @title Get Hits P1
    function getHitsP1() public constant returns(uint length) {
        // @dev    An array of Player1's successful guesses.  I.e., a 'hit' is a guess of Player1 that correctly 
        //         identifies the position of one of Player2's ships
        // @param  getHitsP1  Array
        // @return length     The number of successful guesses / hits, i.e., guesses == ship positions
        return p1Hits.length;
    }
    
    // @title Get Hits P2
    function getHitsP2() public constant returns(uint length) {
        // @dev    An array of Player1's successful guesses.  I.e., a 'hit' is a guess of Player2 that correctly 
        //         identifies the position of one of Player2's ships
        // @param  getHitsP2  Array
        // @return length     The number of successful guesses / hits, i.e., guesses == ship positions
        return p2Hits.length;
    }

    // @dev   Get Turn Count
    // @dev   Not yet implemented
    // @dev   Attempting a work around to get the count of a variable: turnCount
    // @param turnCount is a counter of successive 'plays', i.e., turns, by Player1 and Player2
    // function getTurnCount() public constant returns(int){
    //     if (int(turnCount) == 0) {
    //         return 0;
    //     } else {
    //         return int(turnCount);
    //     }
    // } 
    
    // ================================================================================
    // ACTION:  player 1 initiates a game by submitting the entry fee
    // NOTE:    turncount is initialized to 0.  This is the first turn
    // ================================================================================
    
    // @title Start Game
    function startGame()
        // @dev   Player1 starts a Battleship Game by submitting a 5 ether entrance fee
        // @dev   The function is called once
        // @param turnCount      Initialized to 0 by the constructor function.  Incremented after each player's turn.
        // @param startOfGame    An event, initialized when the game starts
        // @param transitionNext This modifier goes to the next stage after the function is done.
        public
        payable
        atStage(Stages.startOfGame)
        transitionNext
    {
        if (turnCount == 0) {
            player1 = msg.sender;
            players.push(player1);
            // @dev pay entry fee to owner aka casino / house
            // @dev variable betting is not enabled, e.g., `require(msg.value > minimumBet);`
            if (msg.value != 5 ether) revert();
            // @dev submit board - conceal / reveal not yet implemented
            p1Board = [1,2,3,4,5];
            balances[owner] += msg.value;
            // @dev increment turnCount
            turnCount++;
        } 
    }
    
    // ================================================================================
    // ACTION:  player 2 accepts the challenge by submitting their bet, and
    //          takes the first shot by submitting a guess (aka board position)
    // NOTE:    this is turn 2, so
    //              player 1 is the 'odd' player [ modulo = 1 ]
    //              player 2 is the 'even' player [ modulo = 0 ]
    // ================================================================================
    
    // @title Accept The Challenge
    function acceptChallenge(uint guess)
        // @dev   Player2 accepts the challenge, submits their bet, and takes the first shot by submitting a guess aka board position
        // @dev   The function is called once
        // @dev   Player 2 accepts the challenge / pays the entry fee and attacks Player1's ships (during 
        // @dev   turnCount 2), so 
        // @dev   Player1 is the 'odd' player [ modulo = 1 ]
        // @dev   Player2 is the 'even' player [ modulo = 0 ]
        // @param turnCount           Initialized to 0 by the constructor function.  Incremented after each 
        //                            player's turn.
        // @param acceptTheChallenge  An event, stage when the challenge is accepted 
        // @param transitionNext      This modifier goes to the next stage after the function is done.
        public
        payable
        atStage(Stages.acceptTheChallenge)
        transitionNext
    {
        if (turnCount == 1) {
            player2 = msg.sender;
            if (msg.value != 5 ether) revert();
            balances[owner] += msg.value;
            // @dev submit board - conceal / reveal not yet implemented
            p2Board = [21,22,23,24,25];
            // @dev initiate an attack with a guess aka position
            // @dev save a 'log' of attacks / positions 
            p2LogOfGuesses.push(guess);
            // @dev increment turnCount
            turnCount++;
        }
    }
    
    // ================================================================================
    // ACTION:  send your guess to your opponent and send the result of their try to them
    // NOTE:    Since their opponents board is 'hidden', only the player receiving 
    //          the hit can state whether a hit or miss occurred
    //
    //          hit = 1; miss = 2
    //
    //          IMPORTANTLY, this is designed to catch a cheater.  We assume players
    //          will honestly return the result of an attack, i.e., correctly send a hit
    //          or miss.  A dishonest player might mark a hit as a miss.  When their 
    //          board is revealed, we'll compare the shots marked misses against the
    //          positions they submitted.
    // ================================================================================
    
    // @title Take Turns Attacking
    function takeTurnsAttacking(uint guess, uint result)
        // @dev   The players take turns attacking (based upon the modulo of turnCount), i.e., submitting a board position 
        // @dev   aka guess to their opponent, until the game is declared over
        // @param timedTransitions       Place a 2-minute time limit on each player's response.  A player not
        // @parma                        responding to an attack within 2 minutes forfeits the game
        // @param takeYourTurnAttacking  An event, stage where alternating attacks occur
        // @param transitionNext         This modifier goes to the next stage after the function is done.
        public
        payable
        timedTransitions
        atStage(Stages.takeYourTurnAttacking)
        transitionNext
    {   
        // @dev player 2
        if ((turnCount != 1) && (turnCount % 2 == 1)) { 
            // @dev start of 2-minute timer to catch forfeits
            startTurn;                               
            
            // @dev make a new guess aka attack / position
            require(isValidNumber(guess));
            // @dev and save your guess
            p2LogOfGuesses.push(guess);
            // @dev send P1 the result of their attack
            player2 = msg.sender;
            // @dev increment turnCount
            turnCount++;
        
        // @dev player 1
        } else if (turnCount % 2 == 0) {
            // @dev start of 2-minute timer to catch forfeits
            startTurn;
            // @dev make a new guess aka attack / position
            require(isValidNumber(guess));
            // @dev and save your guess
            p1LogOfGuesses.push(guess);
            // @dev send P2 the result of their attack
            player1 = msg.sender;
            // @dev increment turnCount
            turnCount++;
        }

    // ================================================================================
    // NOTE:    Since Player1 knows if Player2's guess was a hit / miss, when sending 
    //          the 'result', Player1 logs the hit or miss using the
    //          position sent by (and logged by) Player2
    // ================================================================================
        
        getLengthP1();
        getLengthP2();
        
        if ((turnCount != 1) && (turnCount % 2 == 1)) {         // player 2                              // to catch forfeits    
            if (result == 1) { 
                p1Position = p1LogOfGuesses[getLengthP1()-1];
                p1Hits.push(p1Position);
                p1SuccessfulGuesses++;
                if (p1SuccessfulGuesses == 5) {
                    // Turn storage turn = turn;
                    // turn.gameOver = true;
                    emit GameIsOver(gameId);
                    // (player2, "You win!")
                }
            }
            if (result == 2) {
                p1Position = p1LogOfGuesses[getLengthP1()-1];
                p1Misses[p1Position] = true;
            }
        } else if (turnCount % 2 == 0) {                        // player 1
            if (result == 1) {
                p2Position = p2LogOfGuesses[getLengthP2()-1];
                p2Hits.push(p1Position);
                p2SuccessfulGuesses++;
                if (p2SuccessfulGuesses == 5) {
                    // turn.gameOver = true;
                    emit GameIsOver(gameId);
                    // (player1, "You win!")
                }
            }
            if (result == 2) {
                p2Position = p2LogOfGuesses[getLengthP2()-1];
                p2Misses[p2Position] = true;
            }
        } if (now >= startTurn + 2 minutes) {
            nextStage();
        } 
    }
    
    // @title Get Player1's Log of guesses
    function getP1LogOfGuesses() public view returns(uint[]) {
        return p1LogOfGuesses;
    }
    
    // @title Get Player2's Log of Guesses
    function getP2LogOfGuesses() public view returns(uint[]) {
        return p2LogOfGuesses;
    }
    
    // @title Get Player1's Hits
    function getP1Hits() public view returns(uint) {
        return p1SuccessfulGuesses;
    }
    
    // @title Get Player2's Hits
    function getP2Hits() public view returns(uint) {
        return p2SuccessfulGuesses;
    }
    
    // ================================================================================
    // ACTION:  game ends when:
    //          1. a player has 5 hits, i.e., sinks all of their opponent's ships
    //          2. a player walks away from the game, i.e., does not respond to an
    //             attack in the alloted 2 minutes
    // NOTE:    Payout:
    //          1. Cheating: 
    //              (a) if one player cheats, they lose their funds. 
    //                  - owner gets to keep 2 ether, 
    //                  - winning player gets 8 ether
    //              (b) if both players cheat, the owner keeps the entire pot
    //          2. Sore loser:
    //              We create an incentive to complete the game:
    //               (a) player abandoning game rather than announcing win gets 0
    //               (b) owner gets to keep 2 ether, 
    //               (c) winning player gets 8 ether
    //          3. Good sport:
    //              Losing player announces winning hit to their opponent
    //              (a) owner gets to keep 2 ether,
    //              (b) losing player gets 2 ether,
    //              (c) winning player gets 6 ether.
    // ================================================================================              
    
    // @title Game Over
    function gameOver() 
        // @dev
        // @parma gameIsOver        An event, stage reached when one player has hit all their opponent's ships
        // @param transitionNext    This modifier goes to the next stage after the function is done.
        public 
        payable
        atStage(Stages.gameIsOver)
        transitionNext
    {                                     
        // @dev reveal boards
        if (p1Hits.length == 5) {
            // @dev reveal of P1's board
            // @dev compare to misses P1 reported to P2
            uint i = 0;
            for (i = 0; 0 < p1Board.length; i++) {
                if (p2Misses[i] = true) {
                    badActor1 = player1;    // p1 cheated by calling a hit a miss
                    i++;
                } 
            }
        } else if (p2Hits.length == 5) {   
            // @dev reveal of P2's board
            // @dev compare to misses P2 reported to P1
            for (i = 0; 0 < p2Board.length; i++) {
                if (p1Misses[i] = true) {
                    badActor2 = player2;    // p2 cheated by calling a hit a miss
                    i++;
                } 
            }     
             
        // @dev a player forfeits if they do not respond to an attack within 2 minutes
        // @dev it implies (a) it's still the prior turn / opponent's turn because turnCount hasn't incremented 
        // @dev it implies the winning player will have less hits than the number required to win
        } else if ((turnCount % 2 == 0) && (p1Hits.length < 5)) {
                forfeit1 = player1;
            } else if ((turnCount % 2 == 1) && (p2Hits.length < 5)) {
                forfeit2 = player2;
            }
        } 
    
    // @title Declare Winner
    function declareWinner() 
        // @dev
        // @parma declareTheWinner  An event, stage reached when a player has - preliminarily - won
        public 
        payable
        atStage(Stages.declareTheWinner)
    {   
        // @ dev can test for a null address with 0
        if ((badActor1 == 0) && (badActor2 == 0)) {  
            // @dev Player2 notified Player1 of the winning hit
            // @dev so Player2 earns the 'good sport' incentive
            if (p1Hits.length == 5) {
                                        
                balances[owner] -= 8;
                balances[player1] += 6;
                balances[player2] += 2;
            // @dev Player1 notified Player2 of the winning hit
            // @dev so Player1 earns the 'good sport' incentive
            } else if (p2Hits.length == 5) { 
                balances[owner] -= 8;
                balances[player2] += 6;
                balances[player1] += 2;
        // @dev Player1 forfeits
        } if (forfeit1 != 0) {
            balances[owner] -= 8;
            balances[player2] += 8;
        // @dev Player2 forfeits
        } if (forfeit2 != 0) {
            balances[owner] -= 8;
            balances[player2] += 8;
        // @dev if both Player1 and Player2 cheat, the owner keeps the entrance fees
        } if ((badActor1 != 0) && (badActor2 != 0)) {
        }                                          
        }
    
    }

    // @dev - fallback function - allows contract to accept ETH 
    function () public payable {}
}