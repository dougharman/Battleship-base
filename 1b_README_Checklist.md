# consensys_final_project - Doug Harman

ConsenSys Academy Final Project: Battleship Game - Doug Harman

VERSION 1 - Battleship-base:

Goal: Create a working two-person battleship game (using Remix)

1.	A Truffle project 
    - truffle compile, truffle migrate, and truffle test working
    - can deploy to lite-server with `npm run start`  I did not build out the front-end here; see Version 2.
    - wrote tests for primary functions with one exception, gameOver().  See below.  I did not write tests for helper functions, e.g., getPlayer1, which are used for testing and the React front-end.  See the documentation @dev note in the file.

2.  Installed software:
	  truffle
	  ganache-cli
	  mocha
	  solc
	  web3@0.0.1-beta.26
	  lite-server
	  chai

3.  COURSE REQUIREMENTS:

  Library: 
	(1) Safe Math - Fail: `truffle install example-package-safe-math-lib@1.0.0` is failing with: `Error: Unknown server response 504 when downloading hash QmfUwis9K2SLwnUh62PDb929JzU5J2aFKd4kS1YErYajdq`  Perhaps, because I haven't installed IPFS? Also, using the command: `npm install example-package-safe-math-lib@1.0.0`  There's a safe math package in the NPM Registry; however, it doesn't appear to be for Solidity.
	(2) CounterLib - Win: I implemented the CounterLib code in this article: https://blog.aragon.org/library-driven-development-in-solidity-2bebcaf88736/ by placing the code in the contracts folder, linking it in 2_deploy_contracts, and `using` it in Battleship.sol (`using CounterLib for CounterLib.Counter;`)
	(3) Also installed Ownable and ReentrancyGuard from https://openzeppelin.org/ and added them to the contract using keyword "is" (`contract Battleship is Ownable, ReentrancyGuard`); however, technically, they're not libraries, rather contracts Battleship inherits from


  Circuit breaker / emergency stop: See Design_Pattern_Decisions

  Development server: 
  - VERSION 1 uses lite-server
  - VERSION 2 (below) uses React


VERSION 2 - Battleship-react-app

1.  React 
    - requires copying the Battleship contract's address and abi into the battleship.js file
    - the abi is over 700 lines
    - I did not discover create-react-dapp until Saturday, August 25th
    
    - unfortunately, I couldn't get it wired-up 
      a. MetaMask is now throwing an error!: Something about a sourcemap/inpage.js not being whitelisted.  It's a MetaMask issue that appears to have been resolved several times.
      b. It's running on port 3000 and MetaMask won't connect. MetaMask is on port 8545, the one specified in Battleship.sol truffle.js 

2.  Installed software:
      react
      react-dom
      react-scripts
      web3
      truffle-hdwallet-provider

3. Battleship-react-app can be (a) deployed locally or (b) to Rinkeby
    - can deploy with `npm run ganache` and in a new terminal shell: `npm run migrate` followed by `npm start`
    - Infura seed phrase and account are hardcoded in the deploy file
    - Rinkeby address is hardcoded as an alternate provider in web3.js file


SUMMARY:
  Accomplished: built and deployed a 2-player battleship game
  Incomplete:   
    Commit / reveal design pattern for the game board.  As a result, the gameOver() function 'cheat check' is coded but can not be tested.
    Adding a factory contract to:
    - deploy multiple instances of the game, each with a unique gameId, i.e., each 'battleship' has a gameId
    - record each player's win / loss history, and
    - create a 'leaderboard' showing each player's history
  Modifications considered, not implemented:
    - changing the entrance fee of 5 ETH into a minimumBet of 5 ETH, i.e., introducing variable betting

