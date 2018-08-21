import React, { Component } from 'react'
import BattleshipContract from '../build/contracts/Battleship.json'
import getWeb3 from './utils/getWeb3'

import './css/oswald.css'
import './css/open-sans.css'
import './css/pure-min.css'
import './App.css'

class App extends Component {
  constructor(props) {
    super(props)

    this.state = {
      StartOfGame: 0,
      web3: null,
      contract: null,
      account: null
    }
  }

  componentWillMount() {
    // Get network provider and web3 instance.
    // See utils/getWeb3 for more info.

    getWeb3
    .then(results => {
      this.setState({
        web3: results.web3
      })

      // Instantiate contract once web3 provided.
      this.instantiateContract()
    })
    .catch(() => {
      console.log('Error finding web3.')
    })
  }

  instantiateContract() {
    /*
     * BATTLE EXAMPLE
     *
     * Normally these functions would be called in the context of a
     * state management library, but for convenience I've placed them here.
     */

    const contract = require('truffle-contract')
    const battleship = contract(BattleshipContract)
    battleship.setProvider(this.state.web3.currentProvider)

    // Declaring this for later so we can chain functions on Battleship.
    var battleshipInstance

    // Get accounts.
    this.state.web3.eth.getAccounts((error, accounts) => {
      battleship.deployed().then((instance) => {
        battleshipInstance = instance

        // Stores the turnCount
        return battleshipInstance.set(owner)
      }).then((result) => {
        // Get the value from the contract to prove it worked.
        return battleshipInstance.owner.call()
      }).then((result) => {
        // Get the value from the contract to prove it worked.
        return this.battleship.address
      // }).then((result) => {
        // Update state with the result.
        // return this.setState({ acceptTheChallenge: result.c[1], contract: battleshipInstance, account: accounts[0] })
      })
    })
  }

  handleClick(event) {
    const contract = this.state.contract
    const account = this.state.account

    var value = 3

    constract.set(value, {from: account})
    .then(result => {
      return contract.get.call()
    }).then(result => {
      return this.setState({storageValue: result.c[0]})
    })
  }

  render() {
    return (
      <div className="App">
        <nav className="navbar pure-menu pure-menu-horizontal">
            <a href="#" className="pure-menu-heading pure-menu-link">Truffle Box</a>
        </nav>

        <main className="container">
          <div className="pure-g">
            <div className="pure-u-1-1">
              <h1>Good to Go!</h1>
              <p>Your Truffle Box is installed and ready.</p>
              <h2>Smart Contract Example</h2>
              <p>If your contracts compiled and migrated successfully, below will show a stored value of 5 (by default).</p>
              <p>Try changing the value stored on <strong>line 59</strong> of App.js.</p>
              <p>The stored value is: {this.state.storageValue}</p>
              
            </div>
            <button onClick={this.handleClick.bind(this)}>Set Storage</button>
          </div>
        </main>
      </div>
    );
  }
}

export default App
