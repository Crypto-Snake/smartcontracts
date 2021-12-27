const fs = require('fs');

let addresses = getAddresses();

function getAddresses() {
    return JSON.parse(fs.readFileSync('../addresses_testnet.json', 'utf-8'))
}

let paymentManager;
let paymentManagerProxy;

let PaymentManager = artifacts.require("PaymentManager");
let PaymentManagerProxy = artifacts.require("PaymentManagerProxy");


module.exports = function(deployer) {

    deployer.then(async() => {

        await deployer.deploy(PaymentManager);
        paymentManager = await PaymentManager.deployed();
        console.log(`payment manager address: ${paymentManager.address}`)
        addresses.paymentManager = paymentManager.address;

        await deployer.deploy(PaymentManagerProxy, addresses.paymentManager);
        paymentManagerProxy = await PaymentManagerProxy.deployed();
        console.log(`payment manager proxy address: ${paymentManagerProxy.address}`)
        addresses.paymentManagerProxy = paymentManagerProxy.address;

        paymentManager = await PaymentManager.at(addresses.paymentManagerProxy)
        await paymentManager.initialize(addresses.busd, addresses.nftManagerProxy)

        fs.writeFileSync('addresses_testnet.json', JSON.stringify(addresses));
    })  
}