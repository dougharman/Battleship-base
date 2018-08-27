# consensys_final_project - Doug Harman

ConsenSys Academy Final Project: Battleship Game - Doug Harman


GOAL: Create a two-person battleship game, with features described in 1b_README_Checklist.md


SCENARIO: 
1. An owner (aka the casino) deploys a game.  
2. Player1 starts play by (a) placing their ships on a board, i.e., select positions on a board, (b) creating a hash of the board, and (c) submitting it with an entrance fee.  State / Stage: 'StartOfGame'.  Player2 accepts the challenge by (a) placing their ships on a board, (b) creating a hash of the board, (c) submitting it with an entrance fee, and (d) submitting their first guess (aka attack) of Player1's positions.  State / Stage: 'AcceptTheChallenge'.  Play continues with the players alternating attacks. State / Stage: 'TakeYourTurnAttacking'.
3. Attacks continue until (a) one player has 5 hits or (b) a player does not respond to an attack within 2-minutes.  State / Stage: 'GameIsOver'.
4. After a 'cheat check', a winner is declared.  State / Stage: 'DeclareTheWinner'.  Funds may be withdrawn by the owner and, if neither player cheats, the winning player.  If both payers cheat, the owner keeps both entrance fees.  State / Stage: 'WithdrawTheFunds'.  See RULES below.


HOW WE CATCH CHEATING:
Since neither player knows the other's ship positions, we rely upon the honesty of each player to accurately report hits on their ships to their opponent.  I.e., Player1 attacks Player2's ships.  Player2 responds with "hit" or "miss".  We log the misses that Player2 reports to Player1.  For the 'cheat test', we compare the reported misses to the positions on Player2's board after it's revealed.


NOTE:
The wikipedia description of a battleship game is here: https://en.wikipedia.org/wiki/Battleship_(game).  Milton Bradley introduced the idea of five types of ships of varying size, i.e., board positions occupied.  We did not let ships occupy more than one board position.  That's because (a) while Solidity handles nested dynamic arrays, (b) it's my understanding that abi/js/web3 doesn't support them. So, we could not implement the idea of multiple hits being required to sink a single ship, i.e., a nested array.


RULES:
The events that start play are described above.

A player has 2-minutes to rspond to an attack.

The game ends when:
1. 	A player has 5 hits, i.e., sinks all of their opponent's ships OR
2. 	A player walks away from the game, i.e., does not respond to an
	attack in the required / alloted 2 minutes.  (This implies that a player can win with less than 5 hits).

A winner is declared:
1. Cheating: 
    (a) If one player cheats, they lose their funds. 
        - owner gets to keep 2 ETH (minus gas), 
        - winning player gets 8 ETH (minus gas)
    (b) If both players cheat, the owner keeps the entire pot (10 ETH, i.e., entrance fee x 2)
2. Sore loser: We create an incentive to complete the game: A player abandoning the game rather than announcing hit / win to opponent gets 0.  Then:
     	- owner gets to keep 2 ETH (minus gas), 
     	- winning player gets 8 ETH (minus gas)
3. Good sport: Losing player announces winning hit to their opponent
	    - owner gets to keep 2 ETH (minus gas),
	    - losing player gets 2 ETH (minus gas),
	    - winning player gets 6 ETH (minus gas).


