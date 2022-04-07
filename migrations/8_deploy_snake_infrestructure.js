//truffle migrate --f 8 --to 8 --network bsctestnet
//truffle migrate --f 8 --to 8 --network bscmainnet

const fs = require('fs');
const { EGGS, SNAKES } = require('../constants.js');

let addresses = getAddresses();

function getAddresses() {
    return JSON.parse(fs.readFileSync('../addresses_testnet.json', 'utf-8'))
}

let snakesNFT;
let snakesNFTProxy;
let snakeEggsNFT;
let snakeEggsNFTProxy;
let snakeEggsShop;
let snakeEggsShopProxy;
let snakeArtifactsShop;
let snakeArtifactsShopProxy;
let nftManager;
let nftStatsManager;
let nftArtifactsManager;
let nftPropertiesManager;
let nftManagerRescue;
let nftManagerProxy;
let lockStakingRewardsPool;
let lockStakingRewardsPoolProxy;
let snakeP2P;
let snakeP2PProxy;
let artifactsNFT;
let artifactsNFTProxy;
let farming;
let farmingProxy;

let SnakeArtifactsNFT = artifacts.require("SnakeArtifactsNFT");
let SnakeArtifactsNFTProxy = artifacts.require("SnakeArtifactsNFTProxy");
let SnakesNFT = artifacts.require("SnakesNFT");
let SnakesNFTProxy = artifacts.require("SnakesNFTProxy");
let SnakeEggsNFT = artifacts.require("SnakeEggsNFT");
let SnakeEggsNFTProxy = artifacts.require("SnakeEggsNFTProxy");
let SnakeEggsShop = artifacts.require("SnakeEggsShop");
let SnakeEggsShopProxy = artifacts.require("SnakeEggsShopProxy");
let SnakeArtifactsShop = artifacts.require("SnakeArtifactsShop");
let SnakeArtifactsShopProxy = artifacts.require("SnakeArtifactsShopProxy");
let NFTManager = artifacts.require("NFTManager");
let NFTStatsManager = artifacts.require("NFTStatsManager");
let NFTArtifactsManager = artifacts.require("NFTArtifactsManager");
let NFTManagerRescue = artifacts.require("NFTManagerRescue")
let NFTPropertiesManager = artifacts.require("NFTPropertiesManager");
let NFTManagerProxy = artifacts.require("NFTManagerProxy");
let LockStakingRewardsPool = artifacts.require("LockStakingRewardsPool");
let LockStakingRewardsPoolProxy = artifacts.require("LockStakingRewardsPoolProxy");
let SnakeP2P = artifacts.require("SnakeP2P");
let SnakeP2PProxy = artifacts.require("SnakeP2PProxy");
let Farming = artifacts.require("Farming");
let FarmingProxy = artifacts.require("FarmingProxy");
let Staking = artifacts.require("Staking");
let StakingProxy = artifacts.require("StakingProxy");

async function getSnakeStats(id) {
    nftManager = await NFTManager.at(addresses.nftManagerProxy);
    let stats = await nftManager.getSnakeStats(id);
    console.log(stats)
}

async function getSnakeArtifacts(id) {
    сonsole.log(1)
    nftManager = await NFTArtifactsManager.at(addresses.nftManagerProxy);
    let stats = await nftManager.getSnakeAppliedArtifacts(id);
    console.log(stats)
}

async function getSnakeOwner(id) {
    snakesNFT = await SnakesNFT.at(addresses.snakesNFTProxy);
    let o = await snakesNFT.ownerOf(17);
    console.log(o)
}

async function sendArtifacts(address, count) {
    artifactsNFT = await SnakeArtifactsNFT.at(addresses.snakeArtifactsNFTProxy);

    for (let i = 1; i < 11; i++) {
    await artifactsNFT.safeTransferFrom("0xD4DC28c3B384EA9F3A41a97Cd202d63Dd339474d", address, i, count, "0x0")
    }
}

module.exports = async function(deployer) {

    const deployParams = {
        deploySnakeEggsNFT: false,
        deploySnakesNFT: false,
        deployLockStakingRewardsPool: false,
        deployNFTManager: false,
        deployEggsShop: false,
        deploySnakeArtifactsShop: false,
        deployP2P: false,
        deployFarming: false,
        setupAccessModifiers: false
    }

    deployer.then(async() => {
        //#region DEPLOY SNAKEEGGSNFT STRUCTURE 1/9
        if (deployParams.deploySnakeEggsNFT) {
            console.log("===== Start deploying SnakeEggsNFT structure (1/9) =====");

            await deployer.deploy(SnakeEggsNFT);
            snakeEggsNFT = await SnakeEggsNFT.deployed();
            console.log(`snake eggs nft address: ${snakeEggsNFT.address}`)
            addresses.snakeEggsNFT = snakeEggsNFT.address;

            await deployer.deploy(SnakeEggsNFTProxy, addresses.snakeEggsNFT);
            snakeEggsNFTProxy = await SnakeEggsNFTProxy.deployed();
            console.log(`snake eggs nft proxy address: ${snakeEggsNFTProxy.address}`)
            addresses.snakeEggsNFTProxy = snakeEggsNFTProxy.address;

            snakeEggsNFT = await SnakeEggsNFT.at(addresses.snakeEggsNFTProxy);
            await snakeEggsNFT.initialize("CryptoSnake Egg NFT", "EGGNFT")

            fs.writeFileSync('addresses_testnet.json', JSON.stringify(addresses));
        } else {
            snakeEggsNFT = { address: addresses.snakeEggsNFT };
            snakeEggsNFTProxy = { address: addresses.snakeEggsNFTProxy };
        }
        //#endregion

        //#region DEPLOY SNAKESNFT STRUCTURE 2/9
        if (deployParams.deploySnakesNFT) {
            console.log("===== Start deploying SnakesNFT structure (2/9) =====");

            await deployer.deploy(SnakesNFT);
            snakesNFT = await SnakesNFT.deployed();
            console.log(`snakes nft address: ${snakesNFT.address}`)
            addresses.snakesNFT = snakesNFT.address;

            await deployer.deploy(SnakesNFTProxy, addresses.snakesNFT);
            snakesNFTProxy = await SnakesNFTProxy.deployed();
            console.log(`snakes nft proxy address: ${snakesNFTProxy.address}`)
            addresses.snakesNFTProxy = snakesNFTProxy.address;

            snakesNFT = await SnakesNFT.at(addresses.snakesNFTProxy);
            await snakesNFT.initialize("CryptoSnake NFT", "SNKNFT");

            fs.writeFileSync('addresses_testnet.json', JSON.stringify(addresses));
        } else {
            snakesNFT = { address: addresses.snakesNFT };
            snakesNFTProxy = { address: addresses.snakesNFTProxy };
        }
        //#endregion

        //#region DEPLOY STAKINGREWARDSPOOL 3/9
        if (deployParams.deployLockStakingRewardsPool) {
            console.log("===== Start deploying LockStakingRewardsPool (3/9) =====");

            await deployer.deploy(LockStakingRewardsPool);
            lockStakingRewardsPool = await LockStakingRewardsPool.deployed();
            console.log(`staking rewards pool address: ${lockStakingRewardsPool.address}`);
            addresses.lockStakingRewardsPool = lockStakingRewardsPool.address;

            await deployer.deploy(LockStakingRewardsPoolProxy, addresses.lockStakingRewardsPool);
            lockStakingRewardsPoolProxy = await LockStakingRewardsPoolProxy.deployed();
            console.log(`staking rewards pool proxy address: ${lockStakingRewardsPoolProxy.address}`);
            addresses.lockStakingRewardsPoolProxy = lockStakingRewardsPoolProxy.address;

            lockStakingRewardsPool = await LockStakingRewardsPool.at(addresses.lockStakingRewardsPoolProxy);

            await lockStakingRewardsPool.initialize(addresses.snk, addresses.busd);
            await lockStakingRewardsPool.updateRouter(addresses.router);
            await lockStakingRewardsPool.updateSnakeToken(addresses.snk);

            fs.writeFileSync('addresses_testnet.json', JSON.stringify(addresses));
        } else {
            lockStakingRewardsPool = { address: addresses.lockStakingRewardsPool };
            lockStakingRewardsPoolProxy = { address: addresses.lockStakingRewardsPoolProxy };
        }
        //#endregion

        //#region DEPLOY NFTMANAGER 4/9
        if (deployParams.deployNFTManager) {
            console.log("===== Start deploying NFTManager (4/9) =====");

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

            await deployer.deploy(NFTPropertiesManager);
            nftPropertiesManager = await NFTPropertiesManager.deployed();
            console.log(`NFT properties manager address: ${nftPropertiesManager.address}`)
            addresses.nftPropertiesManager = nftPropertiesManager.address;

            await deployer.deploy(NFTManagerProxy);
            nftManagerProxy = await NFTManagerProxy.deployed();
            console.log(`NFT manager proxy address: ${nftManagerProxy.address}`)
            addresses.nftManagerProxy = nftManagerProxy.address;

            await nftManagerProxy.addImplementationContract(addresses.nftManager);
            await nftManagerProxy.addImplementationContract(addresses.nftStatsManager);
            await nftManagerProxy.addImplementationContract(addresses.nftArtifactsManager);
            await nftManagerProxy.addImplementationContract(addresses.nftManagerRescue);
            await nftManagerProxy.addImplementationContract(addresses.nftPropertiesManager);

            fs.writeFileSync('addresses_testnet.json', JSON.stringify(addresses));

            nftManager = await NFTManager.at(addresses.nftManagerProxy);
            await nftManager.updateStakingPool(addresses.lockStakingRewardsPoolProxy);
            await nftManager.updateRouter(addresses.router);
            await nftManager.updateSnakeToken(addresses.snk);
            
            await nftManager.updateAllowedTokens(addresses.snk, true);

            // await nftManager.updateAllowedTokens(addresses.busd, true);
            // await nftManager.toggleUseWeightedRates();
            // await nftManager.updateTokenWeightedExchangeRate(addresses.busd, "10000000000000000");
            // await snakeEggsShop.updateTokenWeightedExchangeRate(addresses.snk, "1000000000000000000");

            await nftManager.updateSnakeEggsNFT(addresses.snakeEggsNFTProxy);
            await nftManager.updateSnakesNFT(addresses.snakesNFTProxy);
            await nftManager.updateArtifactsNFT(addresses.snakeArtifactsNFTProxy);
            await nftManager.updateCustodian(process.env.CUSTODIAN);
            await nftManager.updateLowerAdmin(process.env.LOWER_ADMIN);

            for (let i = 1; i < 11; i++) {
                await nftManager.updateAllowedArtifacts(i, true);
            }
        } else {
            nftManager = { address: addresses.nftManager };
            nftStatsManager = { address: addresses.nftStatsManager };
            nftArtifactsManager = { address: addresses.nftArtifactsManager };
            nftManagerRescue = { address: addresses.nftManagerRescue };
            nftPropertiesManager = { address: addresses.nftPropertiesManager };
            nftManagerProxy = { address: addresses.nftManagerProxy };
        }
        //#endregion

        //#region DEPLOY SNAKEEGGSSHOP 5/9
        if (deployParams.deployEggsShop) {
            console.log("===== Start deploying SnakeEggsShop (5/9) =====");

            await deployer.deploy(SnakeEggsShop);
            snakeEggsShop = await SnakeEggsShop.deployed();
            console.log(`snake eggs shop address: ${snakeEggsShop.address}`)
            addresses.snakeEggsShop = snakeEggsShop.address;

            await deployer.deploy(SnakeEggsShopProxy, addresses.snakeEggsShop);
            snakeEggsShopProxy = await SnakeEggsShopProxy.deployed();
            console.log(`snake eggs shop proxy address: ${snakeEggsShopProxy.address}`)
            addresses.snakeEggsShopProxy = snakeEggsShopProxy.address;

            snakeEggsShop = await SnakeEggsShop.at(addresses.snakeEggsShopProxy);
            await snakeEggsShop.initialize(addresses.router, addresses.snakeEggsNFTProxy, addresses.nftManagerProxy, addresses.snk, process.env.CUSTODIAN);
            await snakeEggsShop.updateAllowedTokens(addresses.snk, true);
            await snakeEggsShop.setCurrentEggId(66);

            // await snakeEggsShop.updateAllowedTokens(addresses.busd, true);
            // await snakeEggsShop.toggleUseWeightedRates();
            // await snakeEggsShop.updateTokenWeightedExchangeRate(addresses.busd, "10000000000000000");
            // await snakeEggsShop.updateTokenWeightedExchangeRate(addresses.snk, "1000000000000000000");

            fs.writeFileSync('addresses_testnet.json', JSON.stringify(addresses));
        } else {
            snakeEggsShop = { address: addresses.snakeEggsShop };
            snakeEggsShopProxy = { address: addresses.snakeEggsShopProxy };
        }
        //#endregion

        //#region REPLACE SNAKEARTIFACTSSHOP 6/9
        if (deployParams.deploySnakeArtifactsShop) {
            console.log("===== Start deploying SnakeArtifactsShop contract on proxy (6/9) =====");
            await deployer.deploy(SnakeArtifactsShop);
            snakeArtifactsShop = await SnakeArtifactsShop.deployed();
            console.log(`snake artifacts shop address: ${snakeArtifactsShop.address}`)
            addresses.snakeArtifactsShop = snakeArtifactsShop.address;

            await deployer.deploy(SnakeArtifactsShopProxy, addresses.snakeArtifactsShop);
            snakeArtifactsShopProxy = await SnakeArtifactsShopProxy.deployed();
            console.log(`snake artifacts shop proxy address: ${snakeArtifactsShopProxy.address}`)
            addresses.snakeArtifactsShopProxy = snakeArtifactsShopProxy.address;

            snakeArtifactsShop = await SnakeArtifactsShop.at(addresses.snakeArtifactsShopProxy)
            await snakeArtifactsShop.updateAllowedTokens(addresses.busd, true);
            await snakeArtifactsShop.updateAllowedTokens(addresses.snk, true);
            await snakeArtifactsShop.initialize(addresses.snakeArtifactsNFTProxy, addresses.nftManagerProxy, addresses.lockStakingRewardsPoolProxy, "0xD4DC28c3B384EA9F3A41a97Cd202d63Dd339474d");

            fs.writeFileSync('addresses_testnet.json', JSON.stringify(addresses));
        } else {
            snakeArtifactsShop = { address: addresses.snakeArtifactsShop };
            snakeArtifactsShopProxy = { address: addresses.snakeArtifactsShopProxy };
        }
        //#endregion

        //#region DEPLOY SNAKEP2P 7/9
        if (deployParams.deployP2P) {
            console.log("===== Start deploying SnakeP2P (7/9) =====");

            await deployer.deploy(SnakeP2P);
            snakeP2P = await SnakeP2P.deployed();
            console.log(`snake P2P address: ${snakeP2P.address}`)
            addresses.snakeP2P = snakeP2P.address;

            await deployer.deploy(SnakeP2PProxy, addresses.snakeP2P);
            snakeP2PProxy = await SnakeP2PProxy.deployed();
            console.log(`snake P2P proxy address: ${snakeP2PProxy.address}`)
            addresses.snakeP2PProxy = snakeP2PProxy.address;

            fs.writeFileSync('addresses_testnet.json', JSON.stringify(addresses));
        } else {
            snakeP2P = { address: addresses.snakeP2P };
            snakeP2PProxy = { address: addresses.snakeP2PProxy };
        }
        //#endregion

        //#region DEPLOY FARMING 8/9
        if (deployParams.deployFarming) {
            console.log("===== Start deploying Farming (8/9) =====");

            await deployer.deploy(Farming);
            farming = await Farming.deployed();
            console.log(`farming contract address: ${farming.address}`)
            addresses.farming = farming.address;

            await deployer.deploy(FarmingProxy, addresses.farming);
            farmingProxy = await FarmingProxy.deployed();
            console.log(`farming proxy address: ${farmingProxy.address}`)
            addresses.farmingProxy = farmingProxy.address;

            farming = await Farming.at(addresses.farmingProxy);
            await farming.initialize(addresses.snk, addresses.lp, addresses.router);
            await farming.updatePoolProperties(1, addresses.lp, addresses.snk, "15000000000000000000", "44000000000000000000", "70000000000000000000000000", 0)

            await deployer.deploy(Staking);
            staking = await Staking.deployed();
            console.log(`staking contract address: ${staking.address}`)
            addresses.staking = staking.address;

            await deployer.deploy(StakingProxy, addresses.staking);
            stakingProxy = await StakingProxy.deployed();
            console.log(`staking proxy address: ${stakingProxy.address}`)
            addresses.stakingProxy = stakingProxy.address;

            staking = await Staking.at(addresses.stakingProxy);
            await staking.initialize(addresses.snk);
            await staking.updatePoolProperties(1, addresses.snk, addresses.snk, "3000000000000000000", "7000000000000000000", "5000000000000000000000000", 1800)
            await staking.updatePoolProperties(2, addresses.snk, addresses.snk, "5000000000000000000", "11000000000000000000", "10000000000000000000000000", 3600)
            await staking.updatePoolProperties(3, addresses.snk, addresses.snk, "7000000000000000000", "15000000000000000000", "20000000000000000000000000", 7200)
 
            fs.writeFileSync('addresses_testnet.json', JSON.stringify(addresses));
        } else {
            farming = { address: addresses.farming };
            farmingProxy = { address: addresses.farmingProxy };
            staking = { address: addresses.staking };
            stakingProxy = { address: addresses.stakingProxy };
        }
        //#endregion

        //#region SETUP ACCESS MODIFIERS 9/9
        if (deployParams.setupAccessModifiers) {
            console.log("===== Start setuping access modifiers (9/9) =====");

            snakeEggsShop = await SnakeEggsShop.at(addresses.snakeEggsShopProxy);
            await snakeEggsShop.updateNFTManager(addresses.nftManagerProxy);
            await snakeEggsShop.updateAllowedTokens(addresses.snk, true);

            snakeEggsNFT = await SnakeEggsNFT.at(addresses.snakeEggsNFTProxy);
            await snakeEggsNFT.updateNFTManager(addresses.nftManagerProxy);
            await snakeEggsNFT.updateSnakeEggsShop(addresses.snakeEggsShop);

            snakesNFT = await SnakesNFT.at(addresses.snakesNFTProxy);
            await snakesNFT.updateNFTManager(addresses.nftManagerProxy);

            lockStakingRewardsPool = await LockStakingRewardsPool.at(addresses.lockStakingRewardsPoolProxy);
            await lockStakingRewardsPool.updateNFTManager(addresses.nftManagerProxy);

            nftManager = await NFTManager.at(addresses.nftManagerProxy);
            await nftManager.updateSnakeEggsShop(addresses.snakeEggsShop);
            await nftManager.updateBlackMambaRequiredStakeAmount("2100000000000000000000");

            //call with SnakeArtifactsNFT owner
            // artifactsNFT = await SnakeArtifactsNFT.at(addresses.snakeArtifactsNFTProxy)
            // await artifactsNFT.updateAllowedAddresses(addresses.nftManagerProxy, true)

            nftPropertiesManager = await NFTPropertiesManager.at(addresses.nftManagerProxy);

            for (let i = 0; i < EGGS.length; i++) {
                await nftPropertiesManager.updateSnakeProperties(i+1, [SNAKES[i].name, SNAKES[i].description, SNAKES[i].uri, SNAKES[i].type, SNAKES[i].deathPoint]);
                await nftPropertiesManager.updateEggProperties(i+1, [EGGS[i].name, EGGS[i].description, EGGS[i].uri, EGGS[i].snakeType, EGGS[i].price, EGGS[i].hatchingPeriod]);
            }
        }
        //#endregion
    })
}