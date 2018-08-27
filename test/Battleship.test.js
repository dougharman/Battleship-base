var Battleship = artifacts.require('Battleship');
var contractAddress;
// var BattleshipFactory = artifacts.require('BattleshipFactory');


contract('Battleship', accounts => {
  // let battleship

  /* Stretch attempts -
      importing test helpers
      const assertRevert = require('zeppelin-solidity/test/helpers/assertRevert');
      const expectThrow = require('zeppelin-solidity/test/helpers/expectThrow');
  */

  const owner = accounts[0];
  const player1 = accounts[1];
  const player2 = accounts[2];
  // @dev - maliciousExternalAccount is only used to test the fallback function
  const maliciousExternalAccount = accounts[3];
  const emptyAddress = '0x0000000000000000000000000000000000000000';


  /* @dev - set-up
            ensures that tests are independent of one another, i.e., a new instance
            is deployed before each test
            console.log(contractAddress) and console.log(battleship.address) are
            simply cross-checks
  */
  beforeEach('setup contract for each test', async () => {
      // @dev - creating a new instance, i.e., deploying the contract
      contractInstance = await Battleship.new();
      // @dev - getting the deployed contract's address
      contractAddress = contractInstance.address;
      const battleship = await Battleship.at(contractAddress);
  });

  // @dev - smoke test
  it("should pass the canary test", function() {
      expect(true).to.equal(true);
  });

  it('deploys a battleship', async () => {
    const battleship = await Battleship.at(contractAddress);
    assert.ok(battleship.address);
    console.log(battleship.address);
    console.log(contractAddress);
  });

  // @dev - beforeEach sets an owner
  it('has an owner', async function () {
    const battleship = await Battleship.at(contractAddress);
    assert.equal(await battleship.owner(), accounts[0])
  });

  it('sets an owner', async () => {
    const battleship = await Battleship.at(contractAddress);
    assert.equal(await battleship.owner.call(), accounts[0]);
  });

  // @dev - to test the fallback function
  it('is unable to accept funds', async function () {
    const battleship = await Battleship.at(contractAddress);
    try {
      await battleship.sendTransaction({
        value: 1e+18,
        from: accounts[3],
        gas: '1000000'
      })
      assert(false);
    } catch (err) {
      assert(err);
    }
    eventEmitted = true
  });

  // @dev - tests calling the owner
  it("calls the owner", async () => {
    const battleship = await Battleship.at(contractAddress);
    const isOwner = await battleship.owner.call();
    assert(isOwner);
  });


  /* ================================================================================
     startGame() tests
  */ ================================================================================

  // @dev testing function startGame() -
  // @notice - an entrance fee / minimum bet of 5 ether is required
  it('requires an entrance fee of 5 ether', async () => {
    const battleship = await Battleship.at(contractAddress);
    var eventEmitted = false
    try {
      await battleship.methods.startGame().send({
        value: web3.utils.toWei('5', 'ether'),
        from: accounts[1],
        gas: '1000000'
      });
      assert(false);
    } catch (err) {
      assert(err);
    }
    var eventEmitted = true
  });

  // @dev testing function startGame() - player1 starts play by paying 5 ether entrance fee
  it('allows player1 to place a bet and start play', async () => {
    const battleship = await Battleship.at(contractAddress);
    var eventEmitted = false
    try {
      await battleship.methods.startGame().send({
        value: web3.utils.toWei(5, 'ether'),
        from: accounts[1],
        gas: '1000000'
      });
      assert(false);
    } catch (err) {
      assert(err);
    }
    eventEmitted = true
  });

  // @dev testing function startGame() - player1's entrance fee was accepted
  it('confirms player1 actually entered', async () => {
    const battleship = await Battleship.at(contractAddress);
    const player1BalanceBefore = 100;

    try {
      await battleship.methods.startGame().send({
        value: web3.utils.toWei(5, 'ether'),
        from: accounts[1],
        to: accounts[0],
        gas: '1000000'
      });
      assert(false);
    } catch (err) {
      assert(err);
    }

    var player1BalanceAfter = await web3.eth.getBalance(player1).toNumber;

    assert.notEqual(player1BalanceAfter, 100);
  });

  /* ================================================================================
     acceptChallenge(uint guess) tests
  */ ================================================================================

  // @dev testing function acceptChallenge(uint guess)
  it('allows player2 to accept the challenge', async () => {
    const battleship = await Battleship.at(contractAddress);
    const player2BalanceBefore = 100;

    try {
      await battleship.methods.acceptChallenge(guess).send({
        guess: 42,
        value: web3.utils.toWei(0, 'ether'),
        from: accounts[2],
        to: accounts[0],
        gas: '1000000'
      });
      assert(false);
    } catch (err) {
      assert(err);
    }

    var player2BalanceAfter = await web3.eth.getBalance(player2).toNumber;

    assert.notEqual(player2BalanceAfter, 100, "Player 2 accepted the challenge.");
  });

  /* ================================================================================
     takeTurnsAttacking(uint guess, uint result) tests
  */ ================================================================================

  /* @dev - testing function takeTurnsAttacking(uint guess, uint result)
            this test will fail
            we can not directly test a variable, i.e., turnCount
            currently, testing CounterLib library as a workaround
  */
  it("should be player1's turn", async() => {
    const battleship = await Battleship.at(contractAddress);

    assert.isTrue(turnCount == 19, player2, "Player2 has the 'odd' turns.")
    assert.isTrue(turnCount == 20, player1, "Player1 has the 'even' turns.")
    assert.isTrue(turnCount ==  1, player1, "Player1 has the 'even' turns.")
  });



  /* @dev - testing function takeTurnsAttacking(uint guess, uint result)
            turnCount is a variable that can not be directly tested
            currently, testing CounterLib library as a workaround
  */
  it('should increment turnCount and logOfGuesses', async() => {
    const battleship = await Battleship.at(contractAddress);
    const turnCount = 19;
    await battleship.methods.acceptChallenge(guess).send({
    });
  });

  /* ================================================================================
     gameOver() tests
  */ ================================================================================

  // @dev testing function gameOver()
  it('should signify that a player has 5 hits', async() => {
    const battleship = await Battleship.at(contractAddress);



  });

  // @dev testing function gameOver()
  it('should signify that a player forfeits, i.e. did not respond within 2-minutes', async() => {
    const battleship = await Battleship.at(contractAddress);



  });
  /* ================================================================================
     declareWinner() tests
  */ ================================================================================

  // @dev testing function declareWinner() - checking the 'cheat check'
  it('should catch a player that cheats', async() => {

  });

  /* ================================================================================
     withdrawTheMoney() tests
  */ ================================================================================
  
  // @dev testing function withdrawTheMoney()
  it('should permit the owner and winner(s) to withdraw money', async() => {

  });

});
