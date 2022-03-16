
const fs = require('fs');
const Web3 = require('web3');
const constants = require('../constants.js')

let addresses = require('../addresses_testnet.json');
const { get } = require('http');

let snakeArtifactsNFT;
let snakeArtifactsShop;
let nftManager;

let SnakeArtifactsNFT = artifacts.require("SnakeArtifactsNFT");
let SnakeArtifactsShop = artifacts.require("SnakeArtifactsShop");
let SnakeArtifactsShopProxy = artifacts.require("SnakeArtifactsShopProxy");
let NFTPropertiesManager = artifacts.require("NFTPropertiesManager");


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
        snakeArtifactsNFT = await SnakeArtifactsNFT.at(addresses.snakeArtifactsNFTProxy);
        nftManager = await NFTPropertiesManager.at(addresses.nftManagerProxy);
        snakeArtifactsShop = await SnakeArtifactsShop.at(addresses.snakeArtifactsShopProxy);

        await snakeArtifactsShop.updateAllowedTokens(addresses.snk, true);

        for (const artifact of constants.ARTIFACTS) {
            await nftManager.updateArtifactProperties(artifact.id, [artifact.name, artifact.description, artifact.uri, artifact.price])
        }

        let ids = constants.ARTIFACTS.map((a) => { return a.id });

        let amounts = constants.ARTIFACTS.map((a) => { return a.amount });

        await snakeArtifactsNFT.mintBatch("0xD4DC28c3B384EA9F3A41a97Cd202d63Dd339474d", ids, amounts, constants.OZ.ZERO_BYTES32)

        let pTotalSupplies = ids.map((id) => { return snakeArtifactsNFT.totalSupply(id) });
        let totalSupplies = await (await Promise.all(pTotalSupplies)).map((b) => (b.toString()));

        console.log('total supplies:', totalSupplies);

        let pBalances = ids.map((id) => { return snakeArtifactsNFT.balanceOf("0xD4DC28c3B384EA9F3A41a97Cd202d63Dd339474d", id) })
        let balances = await (await Promise.all(pBalances)).map((b) => (b.toString()));
        console.log('owner balances:', balances)
    })
}