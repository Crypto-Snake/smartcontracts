//truffle migrate --f 11 --to 11 --network bsctestnet
const fs = require('fs');

let addresses = getAddresses();

function getAddresses() {
    return JSON.parse(fs.readFileSync('../addresses_mainnet.json', 'utf-8'))
}

let snakesNFT;
let snakesNFTProxy;
let snakeEggsNFT;
let snakeEggsNFTProxy;
let nftManager;
let nftStatsManager;
let nftArtifactsManager;
let nftManagerRescue;
let nftManagerProxy;
let lockStakingRewardsPool;
let lockStakingRewardsPoolProxy;
let snakeP2P;
let snakeP2PProxy;
let snakeArtifactsNFT;
let snakeArtifactsNFTProxy;

let SnakeArtifactsNFT = artifacts.require("SnakeArtifactsNFT");
let SnakeArtifactsNFTProxy = artifacts.require("SnakeArtifactsNFTProxy");
let SnakesNFT = artifacts.require("SnakesNFT");
let SnakesNFTProxy = artifacts.require("SnakesNFTProxy");
let SnakeEggsNFT = artifacts.require("SnakeEggsNFT");
let SnakeEggsNFTProxy = artifacts.require("SnakeEggsNFTProxy");
let NFTManager = artifacts.require("NFTManager");
let NFTStatsManager = artifacts.require("NFTStatsManager");
let NFTArtifactsManager = artifacts.require("NFTArtifactsManager");
let NFTManagerRescue = artifacts.require("NFTManagerRescue");

let NFTManagerProxy = artifacts.require("NFTManagerProxy");
let LockStakingRewardsPool = artifacts.require("LockStakingRewardsPool");
let LockStakingRewardsPoolProxy = artifacts.require("LockStakingRewardsPoolProxy");
let SnakeP2P = artifacts.require("SnakeP2P");
let SnakeP2PProxy = artifacts.require("SnakeP2PProxy")

module.exports = async function(deployer) {
    const deployParams = {
        replaceSnakeArtifactsNFT: false,
        replaceSnakeEggsNFT: false,
        replaceSnakesNFT: false,
        replaceLockStakingRewardsPool: false,
        replaceNFTManager: true,
        replaceP2P: false,
    }

    deployer.then(async( err, res ) => {
        //#region REPLACE SNAKEARTIFACTSNFT STRUCTURE 1/6
        if (deployParams.replaceSnakeArtifactsNFT) {
            console.log("===== Start replacing SnakeArtifactsNFT contract on proxy (1/6) =====");

            await deployer.deploy(SnakeArtifactsNFT);
            snakeArtifactsNFT = await SnakeArtifactsNFT.deployed();
            console.log(`snake artifacts nft address: ${snakeArtifactsNFT.address}`)
            addresses.snakeArtifactsNFT = snakeArtifactsNFT.address;

            snakeArtifactsNFTProxy = await SnakeArtifactsNFTProxy.at(addresses.snakeArtifactsNFTProxy);
            await snakeArtifactsNFTProxy.replaceImplementation(addresses.snakeArtifactsNFT)

            fs.writeFileSync('addresses_mainnet.json', JSON.stringify(addresses));
        } else {
            snakeArtifactsNFT = { address: addresses.snakeArtifactsNFT };
            snakeArtifactsNFTProxy = { address: addresses.snakeArtifactsNFTProxy };
        }
        //#endregion

        //#region REPLACE SNAKEEGGSNFT STRUCTURE 2/6
        if (deployParams.replaceSnakeEggsNFT) {
            console.log("===== Start replacing SnakeEggsNFT contract on proxy (2/6) =====");

            await deployer.deploy(SnakeEggsNFT);
            snakeEggsNFT = await SnakeEggsNFT.deployed();
            console.log(`snake eggs nft address: ${snakeEggsNFT.address}`)
            addresses.snakeEggsNFT = snakeEggsNFT.address;

            snakeEggsNFTProxy = await SnakeEggsNFTProxy.at(addresses.snakeEggsNFTProxy);
            await snakeEggsNFTProxy.replaceImplementation(addresses.snakeEggsNFT)

            fs.writeFileSync('addresses_mainnet.json', JSON.stringify(addresses));
        } else {
            snakeEggsNFT = { address: addresses.snakeEggsNFT };
            snakeEggsNFTProxy = { address: addresses.snakeEggsNFTProxy };
        }
        //#endregion

        //#region REPLACE SNAKESNFT STRUCTURE 3/6
        if (deployParams.replaceSnakesNFT) {
            console.log("===== Start replacing SnakesNFT contract on proxy (3/6) =====");

            await deployer.deploy(SnakesNFT);
            snakesNFT = await SnakesNFT.deployed();
            console.log(`snakes nft address: ${snakesNFT.address}`)
            addresses.snakesNFT = snakesNFT.address;

            snakesNFTProxy = await SnakesNFTProxy.at(addresses.snakesNFTProxy);
            await snakesNFTProxy.replaceImplementation(addresses.snakesNFT);

            fs.writeFileSync('addresses_mainnet.json', JSON.stringify(addresses));
        } else {
            snakesNFT = { address: addresses.snakesNFT };
            snakesNFTProxy = { address: addresses.snakesNFTProxy };
        }
        //#endregion

        //#region REPLACE STAKINGREWARDSPOOL 4/6
        if (deployParams.replaceLockStakingRewardsPool) {
            console.log("===== Start replacing LockStakingRewardsPool contract on proxy (4/6) =====");

            await deployer.deploy(LockStakingRewardsPool);
            lockStakingRewardsPool = await LockStakingRewardsPool.deployed();
            console.log(`staking rewards pool address: ${lockStakingRewardsPool.address}`);
            addresses.lockStakingRewardsPool = lockStakingRewardsPool.address;

            lockStakingRewardsPoolProxy = await LockStakingRewardsPoolProxy.at(addresses.lockStakingRewardsPoolProxy);
            await lockStakingRewardsPoolProxy.replaceImplementation(addresses.lockStakingRewardsPool);

            fs.writeFileSync('addresses_mainnet.json', JSON.stringify(addresses));
        } else {
            lockStakingRewardsPool = { address: addresses.lockStakingRewardsPool };
            lockStakingRewardsPoolProxy = { address: addresses.lockStakingRewardsPoolProxy };
        }
        //#endregion

        //#region REPLACE NFTMANAGER 5/6
        if (deployParams.replaceNFTManager) {
            console.log("===== Start replacing NFTManager contracts on proxy (5/6) =====");

            await deployer.deploy(NFTManager);
            nftManager = await NFTManager.deployed();
            console.log(`NFT manager address: ${nftManager.address}`)
            addresses.nftManager = nftManager.address;

            await deployer.deploy(NFTStatsManager);
            nftStatsManager = await NFTStatsManager.deployed();
            console.log(`NFT stats manager address: ${nftStatsManager.address}`)
            addresses.nftStatsManager = nftStatsManager.address;

            await deployer.deploy(NFTArtifactsManager);
            nftArtifactsManager = await NFTArtifactsManager.deployed();
            console.log(`NFT artifacts manager address: ${nftArtifactsManager.address}`)
            addresses.nftArtifactsManager = nftArtifactsManager.address;

            await deployer.deploy(NFTManagerRescue);
            nftManagerRescue = await NFTManagerRescue.deployed();
            console.log(`NFT rescue manager address: ${nftManagerRescue.address}`)
            addresses.nftManagerRescue = nftManagerRescue.address;

            nftManagerProxy = await NFTManagerProxy.at(addresses.nftManagerProxy);
            
            await nftManagerProxy.addImplementationContract(addresses.nftManager);
            await nftManagerProxy.addImplementationContract(addresses.nftStatsManager);
            await nftManagerProxy.addImplementationContract(addresses.nftArtifactsManager);
            await nftManagerProxy.addImplementationContract(addresses.nftManagerRescue);

            fs.writeFileSync('addresses_mainnet.json', JSON.stringify(addresses));
        } else {
            nftManager = { address: addresses.nftManager };
            nftStatsManager = { address: addresses.nftStatsManager };
            nftArtifactsManager = { address: addresses.nftArtifactsManager };
            nftManagerProxy = { address: addresses.nftManagerProxy };
        }
        //#endregion

        // //#region REPLACE SNAKEP2P 6/6
        if (deployParams.replaceP2P) {
            console.log("===== Start replacing SnakeP2P contract on proxy (6/6) =====");

            await deployer.deploy(SnakeP2P);
            snakeP2P = await SnakeP2P.deployed();
            console.log(`snake P2P address: ${snakeP2P.address}`)
            addresses.snakeP2P = snakeP2P.address;

            snakeP2PProxy = await SnakeP2PProxy.at(addresses.snakeP2PProxy);
            await snakeP2PProxy.setTarget(addresses.snakeP2P);

            fs.writeFileSync('addresses_mainnet.json', JSON.stringify(addresses));
        } else {
            snakeP2P = { address: addresses.snakeP2P };
            snakeP2PProxy = { address: addresses.snakeP2PProxy };
        }
        //#endregion
    })
}