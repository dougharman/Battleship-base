# consensys_final_project
ConsenSys Academy Final Project: Battleship Game

Goal: Create a two-person battleship game, with these features:

Actions:
Set-up computer
x1. 	install npm					
			npm install npm@5.6.0 with node -v 8.11.3 
			from https://www.npmjs.com/get-npm
x2. 	install ganache
			npm install -g ganache-cli, -v 6.6.6 
x3. 	install truffle from https://truffleframework.com/docs/getting_started/installation
			npm install -g truffle, -v 4.1.13, and
			Solidity -v 0.4.24
4. 	install web3.js from https://github.com/ethereum/web3.js/
			npm install web3 or use <script></script>
5. 	install lite-server from https://github.com/johnpapa/lite-server
			npm install lite-server --save-dev


Set-up project12
x1. truffle init					
		in an empty folder:
	  `truffle init` and `truffle unbox` must be executed in an empty folder.
x2. created a public git repository
	  cloned it to computer, and
	  then copied the git folder and README.md file into the consensys_final_project folder
3. add (empty) contract file
		Battleship.sol to contracts folder
4. add deployment file to migrations folder
		2_deploy_contracts.js - following pattern of course examples
5. add .js and .sol (empty) test files
6. modify config. file      	
		truffle.js - following pattern of course examples for ganache

Coding Process
1. launch ganache
2. write .js and .sol canary test 
3. write .sol empty contract
4. truffle compile
5. truffle migrate
6. truffle test
7. red, green, refactor - both .js and .sol canary tests pass w/o refactoring

Onward!






