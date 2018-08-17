pragma solidity ^0.4.24;


contract BattleshipFactory {
    address[] public deployedBattleships;

    function createBattleship() public {

        address newBattleship = new Battleship();
        deployedBattleships.push(newBattleship);
    }

    function getDeployedBattleships() public view returns (address[]) {
        return deployedBattleships;
    }
}

contract Battleship {

    // ================================================================================
    // GLOBAL VARIABLES
    // ================================================================================
    address public owner;
    address public player1;
    address public player2;
    mapping (address => uint) public balances;

    int[] internal p1Board;
    int[] internal p2Board;

    uint[] public gameId;
    uint public minimumBet;

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
    uint public turnCount;      // decided to increment turnCount rather than
                                // use `Turns[] public turns;` with State, i.e.,
                                // create a State `nextTurn` and then
                                // step through sequential turns with (a) functions,
                                // e.g., `function turnOne() {}`, `function
                                // turnTwo() {}` or (b) a for loop - whose
                                // gas cost increases linearly with the number
                                // of iterations
    
    struct Turn {
        uint guess;
        uint result;
        bool gameOver;
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
    

    // ================================================================================
    // STATE 
    // ================================================================================
    enum Stages { 
        startOfGame,          // start game
        acceptTheChallenge,    // begin play
        takeYourTurnAttacking, // take turns attacking
        gameIsOver,           // end of play
        declareTheWinner       // declare winner and payout
    }
    
    // This is the current stage.
    Stages public stage = Stages.startOfGame;

    uint public startTurn = now;

    modifier atStage(Stages _stage) {
        require(stage == _stage);
        _;
    }
    
    // This modifier goes to the next stage
    // after the function is done.
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
    event StartOfGame(uint turnCount);
    event AcceptTheChallenge(uint turnCount);
    event TakeTurnsAttacking(uint turnCount);
    event GameOver(address _from, string _string);  // add uint _gameId
    event DeclareWinner();
    
    // ================================================================================
    // GAME 
    // ================================================================================

    constructor() public payable {
        owner = msg.sender;    // casino deploys contract and holds bets
        balances[owner] = 0;
        turnCount = 0;
    }
    
    function isValidNumber(uint _guess) private pure returns (bool) {
        return _guess >= 1 && _guess <= 100;
    }
    
    function getLengthP1() public constant returns(uint length) {
        return p1LogOfGuesses.length;
    }
    
    function getLengthP2() public constant returns(uint length) {
        return p2LogOfGuesses.length;
    }
    
    function getHitsP1() public constant returns(uint length) {
        return p1Hits.length;
    }
    
    function getHitsP2() public constant returns(uint length) {
        return p2Hits.length;
    }
    
    // ================================================================================
    // ACTION:  player 1 initiates a game by submitting the entry fee
    // NOTE:    turncount is initialized to 0.  This is the first turn
    // ================================================================================
    
    // player 1 initiates a game
    // function startGame(address creator)             // see BattleshipFactory
    function startGame()
        public
        payable
        atStage(Stages.startOfGame)
        transitionNext
    {
        if (turnCount == 0) {
            // pay entry fee to owner aka casino / house
            // player1 = creator;                   // see BattleshipFactory
            player1 = msg.sender;
            if (msg.value != 5 ether) revert();  // pay entry fee to owner
            // require(msg.value > minimumBet);  // variable betting not enabled
            // submit board
            p1Board = [1,55,56];                // TEST ONLY - REMOVE
            balances[owner] += msg.value;
            turnCount++;                        // or turns.push(newTurn);
        } 
    }
    
    // ================================================================================
    // ACTION:  player 2 accepts the challenge by submitting their bet, and
    //          takes the first shot by submitting a guess (aka board position)
    // NOTE:    this is turn 2, so
    //              player 1 is the 'odd' player [ modulo = 1 ]
    //              player 2 is the 'even' player [ modulo = 0 ]
    // ================================================================================
    
    // player 2 accepts the challenge, submits their bet, and
    // takes the first shot by submitting a guess aka board position
    function acceptChallenge(uint guess) 
        public
        payable
        atStage(Stages.acceptTheChallenge)
        transitionNext
    {
        // Player 2 accepts the challenge / pays the entry fee 
        // and attacks player 1 (during turnCount 2), so 
        // player 1 is the 'odd' player [ modulo = 1 ]
        // player 2 is the 'even' player [ modulo = 0 ]
        
        if (turnCount == 1) {
            player2 = msg.sender;
            if (msg.value != 5 ether) revert();
            balances[owner] += msg.value;
            // submit board
            p2Board = [21,22,23];
            // initiate an attack with a guess aka position
            // save a 'log' of attacks / positions 
            p2LogOfGuesses.push(guess);
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
    
    // send your guess to opponent and
    // send result of opponent's try to them
    // hit = 1
    // miss = 2

    function takeTurnsAttacking(uint guess, uint result)
        public 
        payable
        timedTransitions
        atStage(Stages.takeYourTurnAttacking)
        transitionNext
    {   
        
        if ((turnCount != 1) && (turnCount % 2 == 1)) {     // player 2
            startTurn;                               // to catch forfeits    
            require(isValidNumber(guess));
            // make a new guess aka attack / position
            // and save your guess
            p2LogOfGuesses.push(guess);
            // send P1 the result of their attack
            player2 = msg.sender;
            turnCount++;
            
        } else if (turnCount % 2 == 0) {  // player 1
            startTurn;                               // to catch forfeits   
            require(isValidNumber(guess));
            // make a new guess aka attack / position
            // and save your guess
            p1LogOfGuesses.push(guess);
            // send P2 the result of their attack
            player1 = msg.sender;
            turnCount++;
            
        // Since P1 knows if P2's guess was a hit / miss, when sending 
        // the 'result', P1 logs the hit or miss using the
        // position logged by P2 when sending their guess
        }
        
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
                    emit GameOver(player2, "You win!");
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
                    emit GameOver(player1, "You win!");
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
    
    function getP1LogOfGuesses() public view returns(uint[]) {
        return p1LogOfGuesses;
    }
    
    function getP2LogOfGuesses() public view returns(uint[]) {
        return p2LogOfGuesses;
    }
    
    function getP1Hits() public view returns(uint) {
        return p1SuccessfulGuesses;
    }
    
    function getP2Hits() public view returns(uint) {
        return p2SuccessfulGuesses;
    }
    
    // ================================================================================
    // ACTION:  game ends when:
    //          1. a player has 17 hits, i.e., sinks all of their opponent's ships
    //          2. a player walks away from the game, i.e., does not respond to an
    //             attack in the alloted 2 minutes
    // NOTE:    Payout:
    //          1. Cheating: 
    //              (a) if one player cheats, they lose their funds. 
    //                  - owner gets to keep 0.2 ether, 
    //                  - winning player gets 0.8 ether
    //              (b) if both players cheat, the owner keeps the entire pot
    //          2. Sore loser:
    //              We create an incentive to complete the game:
    //               (a) player abandoning game rather than announcing win gets 0
    //               (b) owner gets to keep 0.2 ether, 
    //               (c) winning player gets 0.8 ether
    //          3. Fair win:
    //              (a) owner gets to keep 0.2 ether,
    //              (b) losing player gets 0.2 ether,
    //              (c) winning player gets 0.6 ether.
    // ================================================================================              
    
    function gameOver() 
        public 
        payable
        atStage(Stages.gameIsOver)
        transitionNext
    {                                     // reveal boards
        if (p1Hits.length == 5) {
            // reveal of P1's board
            // compare to misses P1 reported to P2
            uint i = 0;
            for (i = 0; 0 < p1Board.length; i++) {
                if (p2Misses[i] = true) {
                    badActor1 = player1;    // p1 cheated by calling a hit a miss
                    i++;
                } 
            }
        } else if (p2Hits.length == 5) {   
            // reveal of P2's board
            // compare to misses P2 reported to P1

            for (i = 0; 0 < p2Board.length; i++) {
                if (p1Misses[i] = true) {
                    badActor2 = player2;    // p2 cheated by calling a hit a miss
                    i++;
                } 
            }     
             
        // forfeit if do not respond in 2 minutes
        // implies (a) still prior turn / opponent's turn because turnCount hasn't incremented 
        // implies winning player will have less hits than the number required to win
        } else if ((turnCount % 2 == 0) && (p1Hits.length < 5)) {
                forfeit1 = player1;
            } else if ((turnCount % 2 == 1) && (p2Hits.length < 5)) {
                forfeit2 = player2;
            }
        } 
    
    function declareWinner() 
        public 
        payable
        atStage(Stages.declareTheWinner)
    {   
        if ((badActor1 == 0) && (badActor2 == 0)) {  // can test for null address with 0
            if (p1Hits.length == 5) {   // for test purposes 5 rather than 17
                                        // p2 said "You win!"
                                        // so p2 earns completion incentive
                balances[owner] -= 8;
                balances[player1] += 6;
                balances[player2] += 2;
            
            } else if (p2Hits.length == 5) { // for test purposes 5 rather than 17
                                             // p1 said "You win!"
                                             // so p1 earns completion incentive
                balances[owner] -= 8;
                balances[player2] += 6;
                balances[player1] += 2;

        } if (forfeit1 != 0) {    // p1 forteit
            balances[owner] -= 8;
            balances[player2] += 8;
        } if (forfeit2 != 0) {    // p2 forfeit
            balances[owner] -= 8;
            balances[player2] += 8;
        } if ((badActor1 != 0) && (badActor2 != 0)) {    // do nothing,
        }                                          // owner keeps the pot
        }
    
    }

    // for use in testing
    // function fetchTurn() public view returns (uint guess, uint result, bool gameOver) {
    //     guess = turns[guess].guess;
    //     result = turns[result].result;
    //     return (guess, result, gameOver);
    // }
}