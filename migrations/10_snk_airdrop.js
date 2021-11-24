const { USERS } = require('../constants.js')

let addresses = require('../addresses_mainnet.json');

let snake;

let SnakeBEP20 = artifacts.require("SnakeBEP20");

module.exports = function(deployer) {

    deployer.then(async() => {

        snake = await SnakeBEP20.at(addresses.snk);

        for (let i = 0; i < USERS.length; i++) {
            let result = await snake.transfer(USERS[i], "1000000000000000000");
            console.log(`Id: ${i + 1}, address: ${USERS[i]}, amount: 1 SNK, hash: ${result.tx}`);
        }
    })  
}