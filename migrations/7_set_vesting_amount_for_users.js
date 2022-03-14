const Web3 = require('web3');
const constants = require('../constants.js')

let addresses = require('../addresses_mainnet.json');

let snakeVesting;

let SnakeVesting = artifacts.require("SnakeVesting");

module.exports = function(deployer) {
    let currentProvider;

    switch(deployer.network) {
        case "bscmainnet": {
            currentProvider = constants.PROVIDERS.BSC_MAINNET;
            break;
        };
        case "bscmainnet-fork": {
            currentProvider = constants.PROVIDERS.BSC_MAINNET;
            break;
        };
        case "bsctestnet": {
            currentProvider = constants.PROVIDERS.BSC_TESTNET;
            break;
        };
        case "bsctestnet-fork": {
            currentProvider = constants.PROVIDERS.BSC_TESTNET;
            break;
        };
        default: {
            return;
        }
    }

    const web3 = new Web3(currentProvider);

    deployer.then(async() => {
        snakeVesting = await SnakeVesting.at(addresses.snakeVesting);
        let currentTimestamp = (await web3.eth.getBlock(await web3.eth.getBlockNumber())).timestamp;
        let firstPeriod = 1640865600 - currentTimestamp;
        let secondPeriod = 7776000

        for (let i = 0; i < constants.VESTING_AMOUNTS.length; i++) {
            await snakeVesting.vest(constants.USERS[i], constants.VESTING_AMOUNTS[i].toString() + "000000000000000000", firstPeriod, secondPeriod);
            console.log(`Address: ${constants.USERS[i]}, amount: ${constants.VESTING_AMOUNTS[i].toString() + "000000000000000000"} SNK, first period ${firstPeriod}, second period ${secondPeriod}`);
        }
    })  
}