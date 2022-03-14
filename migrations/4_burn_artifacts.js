
const fs = require('fs');
const Web3 = require('web3');
const constants = require('../constants.js')

let addresses = require('../addresses_mainnet.json');

let snakeArtifactsNFT;
let artifactsShop;

let SnakeArtifactsNFT = artifacts.require("SnakeArtifactsNFT");
let ArtifactsShop = artifacts.require("ArtifactsShop");

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
        artifactsShop = await ArtifactsShop.at(addresses.artifactsShop);

        let ids = constants.ARTIFACTS.map((a) => { return a.id });
        let pAmounts = ids.map((id) => { return snakeArtifactsNFT.balanceOf(constants.TOKEN_OWNER, id) });
        let amounts = await (await Promise.all(pAmounts)).map((a) => (a.toString()));

        if(amounts[4] > 700) {
            amounts[4] = '700';
        }

        console.log(amounts);

        let pTotalSupplies = ids.map((id) => { return snakeArtifactsNFT.totalSupply(id) });
        let totalSupplies = await (await Promise.all(pTotalSupplies)).map((b) => (b.toString()));

        console.log('total supplies:', totalSupplies);

        await snakeArtifactsNFT.burnBatch(constants.TOKEN_OWNER, ids, amounts)

        let pBalances = ids.map((id) => { return snakeArtifactsNFT.balanceOf(constants.TOKEN_OWNER, id) })
        let balances = await (await Promise.all(pBalances)).map((b) => (b.toString()));
        console.log(balances)

        pTotalSupplies = ids.map((id) => { return snakeArtifactsNFT.totalSupply(id) });
        totalSupplies = await (await Promise.all(pTotalSupplies)).map((b) => (b.toString()));

        console.log('total supplies:', totalSupplies);
    })
}