# consensys_final_project

This file describes the set-up process

Battleship-base:
1.  `mkdir <file name>` and cd into it
2. 	install npm: `npm install npm@5.6.0 with node -v 8.11.3 ` from https://www.npmjs.com/get-npm  Using v. 5.6.0 because of conflicts.
3.	install truffle: `npm install -g truffle` from https://truffleframework.com/docs/getting_started/installation
4.  in the empty folder created above:	`truffle init` and `truffle unbox` (if used) must be executed in an empty folder.
5.	install ganache-cli, mocha, and solc: `npm install --save ganache-cli mocha solc`
6.	install web3:
	(a) if yarn is installed on your computer: `yarn add web3@1.0.0-beta.26`
	(b) else: `npm install --save web3@1.0.0-beta.26`
7.	install lite-server (if using): `npm install --save lite-server`
8.	edit `package.json`:
	(a) "main":"truffle-config.js" should be "main":"truffle.js" for Linux / Mac OS
	(b) "test":"echo \"Error: no test specified\" && exit 1" should be "test":"mocha"
	(c) if using lite-server, add "start": "lite-server" to scripts and
	(d) create file `bs-config.json` with:
	  	`"server": {
		    "baseDir": ["./src", "./build/contracts"]
		  }
		}`
		see: https://medium.freecodecamp.org/how-you-can-use-lite-server-for-a-simple-development-web-server-33ea527013c9
9.	edit `truffle.js` to add network script (following course examples, i.e., using
	port 8545 for ganache):
	`networks: {
	    development: {
	      host: "127.0.0.1",
	      port: 8545,
	      network_id: "*" // Match any network id
	    }
	  }`
10.	create project repository: `git init`
11. add (empty) contract file to contracts folder, e.g., Battleship.sol
12. add deployment file to migrations folder, i.e., `2_deploy_contracts.js` (following 
	course examples):
	`var Battleship = artifacts.require("Battleship")`
	`module.exports = function(deployer) {
	  deployer.deploy(Battleship);
	};`
13. add (empty) test files to test folder: `Battleship.test.js` and `TestBattleship.sol`
14.	globally, install prettier to re-format the .json abi: `npm install -g prettier`


Now, after writing a test and corresponding code:
1. 	run `truffle compile`
2.	launch `ganache-cli`
3.  run `truffle migrate` or `truffle migrate --reset` 
4.	open MetaMask and create account / sign in using Mnemonic from step 2.  Use Private 
	Network, Localhost 8545
4.  run `truffle test`
5.	run `npm run start` to launch lite-server at localhost:3000; however, should be using
	localhost://127.0.0.1:8545 with ganache


REACT APP SET-UP:
1.   `create-react-app <directory name>` will create directory and skelton application
2.  create battleship.js file in SRC folder
3.  after migration (above), copy battleship / contract address into battleship.js file
4.  copy abi from Battleship.sol/build/contracts/Battleship.json to battleship.js file [currently, about 600 lines]
5.  install web3 into react folder:
	(a) if yarn is installed on your computer: `yarn add web3@1.0.0-beta.26`
	(b) else: `npm install --save web3@1.0.0-beta.26`
6.  run `npm run start` should launch react
7.  log out of MM.  Restart by getting Mnemonic from running instance of ganache-cli, use to seed and set-up MetaMask account in browser; verify first Account address; create MM account 2 and 3 with successive ganache Accounts


REACT DAPP SET-UP:
1. 	`npx create-react-dapp <directory name>`  // 
	- npx is not a typo
	- from: https://www.npmjs.com/package/create-react-dapp
	- cd `<directory name>`
	- npm run ganache

2.  in a new terminal shell:
	- npm run migrate
	- npm start // will launch on localhost:3000  That is correct; ganache runs in the background

3.	IF YOU PREFER GANACHE UI:
	The Ganache UI gives a more visual and interactive interaction to a Ganache testnet. After installing and launching the Ganache UI. Use

	npm run migrate_ganacheUI
	npm run start_ganacheUI
	💡 Restarting the GanachUI is easy but not obvious. Click on the ⚙️ icon in the upper right of the UI. Then click the "Restart" button.

	💡 Truffle migrations are designed to be roughly analogous to database migrations, in that they replace and/or extend the original contracts. Migrations need to be thought through carefully and are case specific. So for simplicity npm run migrate_ganacheUI scripts heavy handedly uses --reset and --compile-all.

Red, Green, Refactor!
Onward!






