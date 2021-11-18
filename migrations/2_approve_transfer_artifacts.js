//node_modules/.bin/truffle.cmd  develop
//deploy -f 2 --to 2 --network bsctestnet --dry-run

const Web3 = require('web3');
const constants = require('../constants.js')

let addresses = require('../addresses_mainnet.json');

let snakeArtifactsNFT;

let SnakeArtifactsNFT = artifacts.require("SnakeArtifactsNFT");

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
        //#region APPROVE TRANSFER NFT 1/1
        snakeArtifactsNFT = await SnakeArtifactsNFT.at(addresses.snakeArtifactsNFTProxy);
        await snakeArtifactsNFT.setApprovalForAll(addresses.artifactsShop, true);
        //#endregion
    })
}