var Battleship = artifacts.require("Battleship");
var CounterLib = artifacts.require("CounterLib");

module.exports = function(deployer) {
  deployer.deploy(CounterLib);
  deployer.link(CounterLib, Battleship);
  deployer.deploy(Battleship);
};

// @dev - I eliminated Rinkeby deployment.


/* @dev

from the Truffle docs: https://truffleframework.com/docs/truffle/getting-started/running-migrations

Deploy library LibA, then link LibA to contract B, then deploy B.
	deployer.deploy(LibA);
	deployer.link(LibA, B);
	deployer.deploy(B);

Link LibA to many contracts
	deployer.link(LibA, [B, C, D]);

*/