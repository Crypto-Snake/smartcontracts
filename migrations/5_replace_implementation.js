
const fs = require('fs');
const Web3 = require('web3');
const constants = require('../constants.js')

let addresses = require('../addresses_mainnet.json');

let snakeArtifactsNFT;
let snakeArtifactsNFTProxy;


let SnakeArtifactsNFT = artifacts.require("SnakeArtifactsNFT");
let SnakeArtifactsNFTProxy = artifacts.require("SnakeArtifactsNFTProxy");

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

    deployer.then(async() => {

        await deployer.deploy(SnakeArtifactsNFT);
        snakeArtifactsNFT = await SnakeArtifactsNFT.deployed();
        console.log(`snake artifacts nft address: ${snakeArtifactsNFT.address}`)
        addresses.snakeArtifactsNFT = snakeArtifactsNFT.address;

        fs.writeFileSync('../addresses_mainnet.json', JSON.stringify(addresses));

        snakeArtifactsNFTProxy = await SnakeArtifactsNFTProxy.at(addresses.snakeArtifactsNFTProxy);
        await snakeArtifactsNFTProxy.replaceImplementation(addresses.snakeArtifactsNFT);
    })
}