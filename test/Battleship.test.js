var Battleship = artifacts.require('Battleship');
// var BattleshipFactory = artifacts.require('BattleshipFactory');

contract('Battleship', function([owner, player1]) {
  
  let battleship

  // @dev - set-up
  beforeEach('setup contract for each test', async function () {
      // battleship = await Battleship.new(owner);
      // deployedBattleships.push(newBattleship);
      battleship = await Battleship.new();
  })

  // @dev - smoke test
  it("should pass the canary test", function() {
      expect(true).to.equal(true);
  });

  // @dev - beforeEach deploys a contract
  it('deploys a battleship', async () => {
    const battleship = await Battleship.deployed();
    assert.ok(battleship.address);
  });

  // @dev - beforeEach sets an owner
  it('has an owner', async function () {
      assert.equal(await battleship.owner(), owner)
  })

  // @dev - tests fallback function
  it('is able to accept funds', async function () {
      await battleship.sendTransaction({ value: 1e+18, from: owner })
      const battleshipAddress = await battleship.address
      assert.equal(web3.eth.getBalance(battleshipAddress).toNumber(), 1e+18)
    })

  // @dev - tests calling the owner
  it("calls the owner", async () => {
    const battleship = await Battleship.deployed();
    const isOwner = await battleship.owner.call();
    assert(isOwner);
  });

  // @dev testing function startGame() - an entrance fee / minimum bet of 5 ether is required
  it('requires an entrance fee of 5 ether', async () => {
    const battleship = await Battleship.deployed();
    try {
      await battleship.methods.startGame().send({ 
        value: web3.utils.toWei('5', 'ether'),
        from: accounts[1]
      });
      assert(false);
    } catch (err) {
      assert(err);
    }
  });

  // @dev testing function startGame() - player1 starts play by paying 5 ether entrance fee
  it('allows player1 to place a bet and start play', async () => {
    const battleship = await Battleship.deployed();
    var eventEmitted = false
    var event = battleship.StartOfGame()
    try {
      await battleship.methods.startGame().send({ 
        value: web3.utils.toWei('5', 'ether'),
        from: accounts[1]
      });
      assert(false);
    } catch (err) {
      assert(err);
    }
    eventEmitted = true
  });

  // @dev testing function startGame() - player1's entrance fee was accepted
  it('confirms player1 exists', async () => {
    const battleship = await Battleship.deployed();
    const isPlayer = await battleship.player1.call();
    assert(isPlayer);
    // assert.ok(player1.address);
    // assert.equal(await battleship.methods.address(player1), accounts[1])
  });

  // @dev testing function startGame() - still stage StartOfGame
  it('confirms player2 has not accepted the challenge yet', async () => {
    const battleship = await Battleship.deployed();
    const isPlayer = await battleship.player2.call();
    const address = '0x0000000000000000000000000000000000000000'
    assert.equal(isPlayer, address);
  });
 
  // @dev testing function startGame() - making sure turnCount increment
  // @dev turnCount is initialized as 0
  // @dev before player1 starts the game
  // it('should return turncount', async () => {
  //   const battleship = await Battleship.deployed();
  //   expected = await battleship.methods.getTurnCount();
  //   assert.equal(0, expected);
  // });

  // // @dev testing function startGame() - after player1 starts the game
  // it('should increment turnCount', async () => {
  //   const battleship = await Battleship.new();
  //   var eventEmitted = false
  //   try {
  //     await battleship.methods.startGame().send({ 
  //       value: web3.utils.toWei('5', 'ether'),
  //       from: accounts[1]
  //     });
  //     assert(false);
  //   } catch (err) {
  //     assert(err);
  //   }
  //   var event = battleship.AcceptTheChallenge()
  //   await event.watch((err,res) => {
  //     turnCount = res.args.turnCount
  //     eventEmitted = true
  //   })
  //   expected = await battleship.methods.getTurnCount();
  //   assert.equal(0, expected);
  // });

  

}); 


//  it('should report new turnCount', async () => {
//    const battleship = await Battleship.deployed();
//    var eventEmitted = false
//    var event = battleship.StartOfGame()
//    await event.watch((err,res) => {
//      turnCount = res.args.turnCount
//      eventEmitted = true
//    })

//  });

  
  
// });
//    // he's checking that account[1] is an approver in mapping approvers
//    // const isContributor = await battleship.methods.approvers(account[1]).call();
//    // assert(isContributor);  
//                  // assert fails if false, since isContributor s/b
//                  // true, can just pass in isContributor

//    const isPlayer = await battleship.methods.players[0].call();
//    assert(isPlayer);

//  });

  // contract('SimpleStorage', function(accounts) {

 //   it("...should store the value 89.", function() {
  //     return SimpleStorage.deployed().then(function(instance) {
  //       simpleStorageInstance = instance;

  //       return simpleStorageInstance.set(89, {from: accounts[0]});
  //     }).then(function() {
  //       return simpleStorageInstance.get.call();
  //     }).then(function(storedData) {
  //       assert.equal(storedData, 89, "The value 89 was not stored.");
  //     });
  //   });

  // });

  

  // it('allows a manager to make a payment request', async () => {
  //  await battleship.methods.createRequest('buy batteries', '100', accounts[1])
  //    .send({
  //      from: accounts[0],   // the manager's address
  //      gas: '1000000'
  //    });
  //  const request = await battleship.methods.requests(0).call(); 
  //                  // since Request[] ... is public, a getter is
  //                  // automatically created for requests  It
  //                  // returns one item
  //  assert.equal('buy batteries', request.description);
  //                  // checking for one from the struct Request is
  //                  // sufficient


  // });

  // it('processes requests', async () => {
    //  await battleship.methods.contribute().send({
    //    from: accounts[],
    //    value: web3.utils.toWei('10', 'ether')     // less than 100 expected, therefore s/ throw
        
    //  });

  //     await battleship.methods
  //       .createRequest('A', web3.utils.toWei('5', 'ether'), accounts[1])
  //       .send({ 
  //        from: accounts[0], 
  //        gas: '1000000' 
  //     });

  //     await battleship.methods.approveRequest(0).send({
  //       from: accounts[0],
  //       gas: '1000000'
  //     });

  //     await battleship.methods.finalizeRequest(0).send({
  //       from: accounts[0],
  //       gas: '1000000'
  //     });

  //     let balance = await web3.eth.getBalance(accounts[1]);
  //     balance = web3.utils.fromWei(balance, 'ether');  // returns a string
  //     balance = parseFloat(balance);         // turns string into a decimal number

  //     assert(balance > 104);
  // });

// describe('Battleships', () => {
//   it('deploys a factory and a battleship', () => {
//     assert.ok(factory.options.address);
//     assert.ok(battleship.options.address);
//   });

//   it('marks caller as the battleship manager', async () => {
//     const manager = await battleship.methods.manager().call();
//     assert.equal(accounts[0], manager);
//   });

//   it('allows people to contribute money and marks them as approvers', async () => {
//     await battleship.methods.contribute().send({
//       value: '200',
//       from: accounts[1]
//     });
//     const isContributor = await battleship.methods.approvers(accounts[1]).call();
//     assert(isContributor);
//   });

//   it('requires a minimum contribution', async () => {
//     try {
//       await battleship.methods.contribute().send({
//         value: '5',
//         from: accounts[1]
//       });
//       assert(false);
//     } catch (err) {
//       assert(err);
//     }
//   });

//   it('allows a manager to make a payment request', async () => {
//     await battleship.methods
//       .createRequest('Buy batteries', '100', accounts[1])
//       .send({
//         from: accounts[0],
//         gas: '1000000'
//       });
//     const request = await battleship.methods.requests(0).call();

//     assert.equal('Buy batteries', request.description);
//   });

//   it('processes requests', async () => {
//     await battleship.methods.contribute().send({
//       from: accounts[0],
//       value: web3.utils.toWei('10', 'ether')
//     });

//     await battleship.methods
//       .createRequest('A', web3.utils.toWei('5', 'ether'), accounts[1])
//       .send({ from: accounts[0], gas: '1000000' });

//     await battleship.methods.approveRequest(0).send({
//       from: accounts[0],
//       gas: '1000000'
//     });

//     await battleship.methods.finalizeRequest(0).send({
//       from: accounts[0],
//       gas: '1000000'
//     });

//     let balance = await web3.eth.getBalance(accounts[1]);
//     balance = web3.utils.fromWei(balance, 'ether');
//     balance = parseFloat(balance);

//     assert(balance > 104);
//     done()
//   });
// });


