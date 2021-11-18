//node_modules/.bin/truffle.cmd  develop
//deploy -f 1 --to 1 --network bsctestnet --dry-run

const fs = require('fs');
const Web3 = require('web3');
const constants = require('../constants.js')

let addresses = require('../addresses_mainnet.json');

let snakeArtifactsNFT;
let snakeArtifactsNFTProxy;
let artifactsShop;

let SnakeArtifactsNFT = artifacts.require("SnakeArtifactsNFT");
let SnakeArtifactsNFTProxy = artifacts.require("SnakeArtifactsNFTProxy");
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

    const web3 = new Web3(currentProvider);

    const deployParams = {
        deploySnakeArtifactsNFT: true,
        mintArtifacts: true,
        deployShop: true,
        setupShop: true
    }

    deployer.then(async() => {

        //#region DEPLOY SNAKEARTIFACTSNFT STRUCTURE 1/4
        if (deployParams.deploySnakeArtifactsNFT) {
            consolelog("===== Start deploying SnakeArtifactsNFT structure (1/4) =====");

            await deployer.deploy(SnakeArtifactsNFT);
            snakeArtifactsNFT = await SnakeArtifactsNFT.deployed();
            console.log(`snake artifacts nft address: ${snakeArtifactsNFT.address}`)
            addresses.snakeArtifactsNFT = snakeArtifactsNFT.address;

            await deployer.deploy(SnakeArtifactsNFTProxy, addresses.snakeArtifactsNFT);
            snakeArtifactsNFTProxy = await SnakeArtifactsNFTProxy.deployed();
            console.log(`snake artifacts nft proxy address: ${snakeArtifactsNFTProxy.address}`)
            addresses.snakeArtifactsNFTProxy = snakeArtifactsNFTProxy.address;

            fs.writeFileSync('../addresses_mainnet.json', JSON.stringify(addresses));
        } else {
            snakeArtifactsNFT = { address: addresses.snakeArtifactsNFT };
            snakeArtifactsNFTProxy = { address: addresses.snakeArtifactsNFTProxy };
        }
        //#endregion

        //#region MINT ARTIFACTS 2/4
        if (deployParams.mintArtifacts) {
            consolelog("===== Start deploying SnakeArtifactsNFT structure (2/4) =====");

            snakeArtifactsNFT = await SnakeArtifactsNFT.at(addresses.snakeArtifactsNFTProxy);

            for (let i = 0; i < constants.ARTIFACTS.length; i++) {
                await snakeArtifactsNFT.mint(constants.TOKEN_OWNER, i + 1, constants.ARTIFACTS[i].amount, constants.OZ.ZERO_BYTES32);
                await snakeArtifactsNFT.setTokenMetadata(i + 1, [constants.ARTIFACTS[i].name, constants.ARTIFACTS[i].description, constants.ARTIFACTS[i].uri]);
                let balance = await snakeArtifactsNFT.balanceOf(constants.TOKEN_OWNER, i + 1)

                console.log(`balance of token ${i + 1}: ${balance}`);
            }
        }
        //#endregion

        //#region DEPLOY ARTIFACTS SHOP 3/4
        if (deployParams.deployShop) {
            consolelog("===== Start deploying SnakeArtifactsNFT structure (3/4) =====");

            await deployer.deploy(ArtifactsShop, addresses.router, addresses.snakeArtifactsNFTProxy, constants.CUSTODIAN, constants.TOKEN_OWNER);
            artifactsShop = await ArtifactsShop.deployed();
            console.log(`snake artifacts shop: ${artifactsShop.address}`)
            addresses.artifactsShop = artifactsShop.address;

            fs.writeFileSync('../addresses_mainnet.json', JSON.stringify(addresses));
        } else {
            artifactsShop = { address: addresses.artifactsShop };
        }
        //#endregion

        //#region SETUP ARTIFACTS SHOP 4/4
        if (deployParams.setupShop) {
            consolelog("===== Start deploying SnakeArtifactsNFT structure (4/4) =====");
            artifactsShop = await ArtifactsShop.at(addresses.artifactsShop);

            await artifactsShop.updateAllowedTokens(addresses.busd, true);
            await artifactsShop.updateTokenWeightedExchangeRate(addresses.busd, (10 ** 20).toString());
            
            for (let i = 0; i < constants.ARTIFACTS.length; i++) {
                await artifactsShop.updateArtifactPrice(i + 1, constants.ARTIFACTS[i].price);
            }
        }
        //#endregion
        
        consolelog("=============== That's all folks ===============");
    });

    function consolelog(message) {
        console.log(message);
        fs.appendFileSync('./local.log', "\r\n" + message + "\t\t\t\t\t" + new Date().toLocaleString("en-GB", { hour12: false }));
    }

    function getCurrentDateEpoch() {
        const now = new Date();
        const res = Math.round(now.getTime() / 1000);
        consolelog(`${res}: ${now}`);
        return res;
    }

    function getCurrentDateEpochPlusDays(days) {
        const now = new Date();
        let res = Math.round(now.getTime() / 1000) + (days * 86400);
        consolelog(`${new Date(res * 1000)}`);
        return res;
    }

    function sleep(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }
};