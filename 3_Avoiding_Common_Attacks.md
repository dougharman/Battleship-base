# consensys_final_project
ConsenSys Academy Final Project: Battleship Game

COURSE REQUIREMENTS:
  Circuit Breakers (Pause contract functionality): https://github.com/ethereum/wiki/wiki/Safety#circuit-breakers-pause-contract-functionality (at the end of the Battleship.sol file)


Explicited addressed:
1.  Restrict amount of Ether per user/contract  https://github.com/ethereum/wiki/wiki/Safety#restrict-amount-of-ether-per-usercontract  Each player submits an entrance fee of 5 ETH.

2.  In 2-party or N-party contracts, beware of the possibility that some participants may "drop offline" and not return  https://github.com/ethereum/wiki/wiki/Safety#in-2-party-or-n-party-contracts-beware-of-the-possibility-that-some-participants-may-drop-offline-and-not-return  The game (a) employs an incentive to keep players engaged, even when losing.  A 'good sport' lets their opponent know their last guess / hit wins the game.  They're rewarded with 2 ETH for doing so.  If 'sore loser' abandons the game, creating a forfeit, they receive nothing. And (b) uses the modifier `timedTransitions()` to enforce the requirement that a player must respond to an attack within 2-minutes or forfeit the game.

2.  Fallback function.  Keep fallback functions simple  https://github.com/ethereum/wiki/wiki/Safety#keep-fallback-functions-simple  We followed the recommendation and use a simple revert, while acknowledging the possibility of funds being sent to the contract via selfdestruct and / or mining.  This example, from the Solidity docs, is misleading.  It uses two unnamed functions: https://solidity.readthedocs.io/en/latest/contracts.html#fallback-function

3.  Reentrancy.  `modifier nonReentrant()` from the OpenZeppelin ReentrancyGuard contract is applied to all payable functions.

Potential Vulnerabilities Remaining in Project:
1. Overflow: We don't know the contract owner's balance; hence, overflows might occur.  Introducing variable betting with a minimumBet would magnify the issue.
2. Cross-function Race Condition: The declareWinner() function allocates funds.  The withdrawMoney function enables the owner and / or player(s) to withdraw funds (using pull rather than push, and `transfer`).  Note, the game was set-up with the owner aka casino holding the funds; hence, the issue.  This probably creates a Cross-function Race Condition  https://github.com/ethereum/wiki/wiki/Safety#cross-function-race-conditions  It can be resolved by: (a) allowing the contract to hold the funds (rather than the owner. Something we started to implement, i.e, creating a factory contract to split manufacture and deployment), (b) setting up an intermediary contract, e.g., EthPM escrow and rate-limiting withdrawals.  The risk is limited by (a) the use of the pull pattern for withdrawals from the contract and (b) they do not share the same State / Stage.


