pragma solidity ^0.4.24;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Battleship.sol";

contract TestBattleship {
	// Battleship battleShip = Battleship(DeployedAddresses.Battleship());
	// Battleship battleship = new Battleship();

	function testConstructor() public {
		Assert.equal(msg.sender, msg.sender, "canary test");
	}

	function testSettingAnOwnerDuringCreation() public {
		Battleship battleship = new Battleship();
		Assert.equal(battleship.owner(), this, "An owner is set.");
	}

}

// function BeforeEachAgain() {
	// 	Battleship battleship = new Battleship();
	// }

	// function testConstructor() public {
	// 	Assert.equal(battleship.owner(), msg.sender, "owner is set equal to msg.sender by constructor");
	// }

	// function testOwnersInitialBalance() public {
	// 	address owner;
	// 	Assert.notEqual(address(owner).balance, 0, "while balance in contract is 0, the balance at the owner address is > 0");
	// }

	// function testPaymentOfEntryFee() public {
	// 	address owner;
	// 	// balances[owner] = 0;
	// 	uint expected = 5;
	// 	Assert.equal(address(owner).balance, expected, "The entrance fee is 5 ether.");
	// }

	// function testStageAtStartOfGame() public {
	// 	uint Stage;
	// 	Assert.equal(Stage, 0, "Stage = Stages.startGame");
	// 	Assert.notEqual(Stage, 4, "Stage is not gameOver");
	// }

	// 	bool expected = true;
	// 	Assert.isTrue(guess, expected);
	// }

	// function testGetLengthP1() {
	// 	Battleship battleShip = Battleship(DeployedAddresses.Battleship());
	// 	p1LogOfGuesses.push(1);
	// 	p1LogOfGuesses.push(2);
	// 	Assert.equal(battleShip.p1LogOfGuesses.length, 2);
	// }
  // function testItStoresAValue() public {
  //   Battleship battleShip = Battleship(DeployedAddresses.Battleship());

  //   battleShip.set(89);

  //   uint expected = 89;

  //   Assert.equal(battleShip.get(), expected, "It should store the value 89.");
  // }

// }
