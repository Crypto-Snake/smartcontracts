const fs = require('fs');

let addresses = getAddresses();

function getAddresses() {
    return JSON.parse(fs.readFileSync('../addresses_testnet.json', 'utf-8'))
}

let farming;
let farmingProxy;

let Farming = artifacts.require("Farming");
let FarmingProxy = artifacts.require("FarmingProxy");


module.exports = function(deployer) {

    deployer.then(async() => {
        await deployer.deploy(Farming);
        farming = await Farming.deployed();
        console.log(`farming contract address: ${farming.address}`)
        addresses.farming = farming.address;

        await deployer.deploy(FarmingProxy, addresses.farming);
        farmingProxy = await FarmingProxy.deployed();
        console.log(`farming proxy contract address: ${farmingProxy.address}`)
        addresses.farmingProxy = farmingProxy.address;

        fs.writeFileSync('addresses_testnet.json', JSON.stringify(addresses));
    })
}