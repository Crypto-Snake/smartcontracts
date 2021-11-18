const fs = require('fs');
const Web3 = require('web3');
const constants = require('../constants.js')

let addresses = require('../addresses_mainnet.json');

let snk;
let snakeVesting;

let SnakeBEP20 = artifacts.require("SnakeBEP20");
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

    const deployParams = {
        deploySnk: false,
        deployVesting: false,
        mintTokens: true
    }

    deployer.then(async() => {

        //#region DEPLOY SNAKE TOKEN 1/3
        if (deployParams.deploySnk) {
            console.log("===== Start deploying Snake token (1/3) =====");
            await deployer.deploy(SnakeBEP20);
            snk = await SnakeBEP20.deployed();
            console.log(`snake address: ${snk.address}`)
            addresses.snk = snk.address;
            fs.writeFileSync('../addresses_mainnet.json', JSON.stringify(addresses));
        } else {
            snk = { address: addresses.snk };
        }
        //#endregion

        //#region DEPLOY SNAKE VESTING 2/3
        if (deployParams.deployVesting) {
            console.log("===== Start deploying Snake vesting (2/3) =====");
            await deployer.deploy(SnakeVesting, addresses.snk);
            snakeVesting = await SnakeVesting.deployed();
            console.log(`snake vesting address: ${snakeVesting.address}`)
            addresses.snakeVesting = snakeVesting.address;
            fs.writeFileSync('../addresses_mainnet.json', JSON.stringify(addresses));
        } else {
            snakeVesting = { address: addresses.snakeVesting };
        }
        //#endregion

        //#region MINT SNAKE TOKEN 3/3
        if (deployParams.mintTokens) {
            console.log("===== Start minting Snake tokens (3/3) =====");
            snk = await SnakeBEP20.at(addresses.snk);
            snakeVesting = await SnakeVesting.at(addresses.snakeVesting);

            // await snk.mintTo(constants.CUSTODIAN, ("100000000" + "000000000000000000"));
            // await snk.mintTo(addresses.snakeVesting, ("59496624" + "000000000000000000"));

            // let custodianBalance = await snk.balanceOf(constants.CUSTODIAN);
            // console.log('custodian balance: ', custodianBalance.toString());
            let vestingBalance = await snk.balanceOf(addresses.snakeVesting);
            // console.log('vesting balance: ', vestingBalance.toString());

            // await snk.transferOwnership(constants.ARTIFACT_OWNER);
            // await snakeVesting.transferOwnership(constants.ARTIFACT_OWNER);

            await snk.acceptOwnership();
            await snakeVesting.acceptOwnership();
        }
        //#endregion
    })
}