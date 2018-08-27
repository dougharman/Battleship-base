# consensys_final_project
ConsenSys Academy Final Project: Ethereum Battleship

COURSE REQUIREMENTS:

Circuit breaker / emergency stop: 
  - See Battleship.sol toggleContractActive(), modifier stopInEmergency, modifier onlyInEmergency, internalDeposit(), and internalWithdraw()
  - We used Ownable here: We assume an emergency occurs when, for example, the Battleship contract's owner is hacked.  Rather than having the 'pot', i.e., 2 x the entrance fee, stolen, the owner calls an emergency stop and transfers control of the contract to his / her new address (with, presumably, a different password).

Commit / reveal design pattern:
  - Because of difficulties implementing the front-end, i.e., learning React, the commit / reveal pattern was not implemented.  In a better world (or with more experience), player1 would start the game by submitting their hashed game board of ships' positions and their entrance fee.  Player2 would respond by submitting their hashed game board of ships' positions, their entrance fee, and initial guess.  When the game is over (State / Stage: gameOver()), the boards would be submitted with their key.  That enables checking, for example, Player2's guesses marked "misses" by Player1 against the positions that Player1 submitted.  
  - As a result, the gameOver() function 'cheat check' is coded but can not currently be fully tested.
  - The commit / reveal pattern is not necessary to play the game, only test for cheating.  That's why the game works; however, gameOver() can't be accurately tested (currently)
  - How we enable play without a submitted / hidden board: Since neither player knows the other's ship positions, we rely upon the honesty of each player to accurately report hits on their ships to their opponent.  I.e., Player1 attacks Player2's ships.  Player2 responds with "hit" or "miss".  
  - How we check for cheating: We log the misses that Player2 reports to Player1.  For the 'cheat test', State / Stage: gameOver(), we compare the reported misses to the positions on Player2's board after it's revealed.  I.e., if a "miss" == a position on Player2's board, then Player2 cheated when responding to Player1's attack, i.e., they did not accurately state that the attack was successful.

State / Stage:
  - We implemented State following the example State Machine (which uses the word Stage rather than State): https://solidity.readthedocs.io/en/v0.4.24/common-patterns.html?highlight=stage#state-machine

Forfeit using a timer:
  - A player forfeits when they do not resond to an attack within 2-minutes
  - The modifier `modifier timedTransitions()` was created following the example State Machine (which uses the word Stage rather than State): https://solidity.readthedocs.io/en/v0.4.24/common-patterns.html?highlight=stage#state-machine

We did not implement Nested Arrays, i.e., ships with more than one board position:
  - The wikipedia description of a battleship game is here: https://en.wikipedia.org/wiki/Battleship_(game).  Milton Bradley introduced the idea of five types of ships of varying size, i.e., board positions occupied.  We did not let ships occupy more than one board position.  
  - While Solidity handles nested dynamic arrays, (b) it's my understanding that abi/js/web3 doesn't support them. So, we could not implement the idea of multiple hits being required to sink a single ship, i.e., a nested array.  More here: https://ethereum.stackexchange.com/questions/28239/how-to-pass-nested-array-values-to-the-solidity-function










