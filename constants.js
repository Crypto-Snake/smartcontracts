const openZeppelinHelper = require('@openzeppelin/test-helpers');

const PROVIDERS = {
    BSC_MAINNET: `https://bsc-dataseed.binance.org/`,
    BSC_TESTNET: `https://data-seed-prebsc-2-s3.binance.org:8545/`
}

const ARTIFACTS_METADATA = {
    mysteryBox : {
        id: 1,
        name: "Mystery box",
        description: "Contains a random number of Snake tokens. Mystery box can contain from 0 to 10,000 Snake tokens.",
        uri: "https://bafybeih67u2nvw2k62cg2s4exdxnnccvu2nisthgi7hpl7zfa3qjyiccke.ipfs.infura-ipfs.io/",
        price: "1000000000000000000000",
        amount: 10000
    },
    diamond: {
        id: 2,
        name: "Diamond",
        description: "Adds 50% to the APR of the snake during the game. Can be applied up to 4 times to one character",
        uri: "https://bafybeiafzvnk6rqgwyob2cud7y7pnl2ekjnkx73m3kksr37gynntlu4d5i.ipfs.infura-ipfs.io/",
        price: "10000000000000000000000",
        amount: 100
    },
    bomb: {
        id: 3,
        name: "Bomb",
        description: "Can increase any TVL (Total Locked Value) by two or more times, but can also destroy the snake and all parameters, including the balance and accrued Snake tokens",
        uri: "https://bafybeicfhwnykg547mu3zipfuqkaxpyulm6s362aybcfpxcicd2xibdxka.ipfs.infura-ipfs.io/",
        price: "30000000000000000000000",
        amount: 500
    },
    meat: {
        id: 4,
        name: "Mouse",
        description: "Increases the snake's TVL by 10%. Can be applied multiple times.",
        uri: "https://bafybeifxcadktftxquoflrqwoooo5lnvixwh5u5ltqlodzklfy6k3n2is4.ipfs.infura-ipfs.io/",
        price: "50000000000000000000000",
        amount: 100
    },
    trophy: {
        id: 5,
        name: "Trophy",
        description: "Lottery trophy. Out of 1000 artifacts, only 100 have an effect, and the rest are dummies. 10% of the income of all players will be distributed among the hundred winners. This 10% will be generated in the form of new tokens, so that the rest of the players will not receive less.",
        uri: "https://bafybeiggph5xjpyfnsicdq725zaz7uk5ieitbcywapn2thjgyma57wlykq.ipfs.infura-ipfs.io/",
        price: "100000000000000000000000",
        amount: 1000
    },
    rainbowUnicorn: {
        id: 6,
        name: "Rainbow unicorn",
        description: "Is a mega cool unique artifact. Those with a rainbow unicorn receive 2% of the APR% of all players every month. The reward is paid in USD to the owner's wallet.",
        uri: "https://bafybeiesjeq7qccp4u2c4vjmnquwe7zisqx74bppzf3ih3sd63gv3hken4.ipfs.infura-ipfs.io/",
        price: "10000000000000000000000000",
        amount: 5
    },
    shadowSnake: {
        id: 7,
        name: "Shadow snake",
        description: "A gift artifact from the team. Increases the snake's TVL twice. It only works if the snake's TVL is more than $100. The artifact must be activated within five days.",
        uri: "https://bafybeif65tn4f3s7fn36rxvpyxqcjlbzb4xqoh6pnxh7jsbbu7wuhmglny.ipfs.infura-ipfs.io/",
        price: 0,
        amount: 50000
    },
    snakeHunter: {
        id: 8,
        name: "Snake hunter",
        description: "After applying this artifact, the entire current APR will be transferred to the character's owner's wallet monthly in Snake tokens, so you don't need to break the snake to get tokens.",
        uri: "https://bafybeigsv6qkxjgmkk7md67eiaxj2jempetp2e3qgylcsyi4vrjv34kib4.ipfs.infura-ipfs.io/",
        price: "20000000000000000000000",
        amount: 500
    },
    snakeCharmer: {
        id: 9,
        name: "Snake charmer",
        description: "After applying this artifact, the entire current APR will be transferred to the character's owner's wallet monthly in USDT tokens, so you don't need to break the snake to get tokens.",
        uri: "https://bafybeihyliq6yjqjnc2rj36hybatchyzt7p4ihwguvn4mnaxptvqex3h5u.ipfs.infura-ipfs.io/",
        price: "100000000000000000000000",
        amount: 100
    },
    snakeTime: {
        id: 10,
        name: "Snake Time",
        description: "Transfers APR percentage to the owner's wallet in Snake tokens without destroying the snake. The artifact can be applied any number of times.",
        uri: "https://bafybeie7ea3im5khbwurcllwocd6enz3io27i3jjsslponebbsbdoumeke.ipfs.infura-ipfs.io/",
        price: "5000000000000000000000",
        amount: 1000
    } 
}

const ARTIFACTS = [
    ARTIFACTS_METADATA.mysteryBox, 
    ARTIFACTS_METADATA.diamond, 
    ARTIFACTS_METADATA.bomb, 
    ARTIFACTS_METADATA.meat, 
    ARTIFACTS_METADATA.trophy,
    ARTIFACTS_METADATA.rainbowUnicorn,
    ARTIFACTS_METADATA.shadowSnake,
    ARTIFACTS_METADATA.snakeHunter,
    ARTIFACTS_METADATA.snakeCharmer,
    ARTIFACTS_METADATA.snakeTime
]

const SNAKES_METADATA = {
    dasypeltis : {
        name: "Dasypeltis",
        description: "Dasypeltis Description",
        uri: "https://ipfs.io/ipfs/QmeEcezaPgNGjoJhPmGEPSatqW1GTw4YoWm3cgWFSPvTSt",
        type: "1",
        deathPoint: "100" + "000000000000000000"
    },
    viper : {
        name: "Viper",
        description: "Viper Description",
        uri: "https://ipfs.io/ipfs/QmQ4ng2srQZoaEpZkcRZqHNqArkJxTMgfZvit37dcrubYe",
        type: "2",
        deathPoint: "100" + "000000000000000000"
    },
    python : {
        name: "Python",
        description: "Python Description",
        uri: "https://ipfs.io/ipfs/QmXCV5addPYXCHYAPD93y5bQvjzQYbouPqcStphWAyXi7L",
        type: "3",
        deathPoint: "100" + "000000000000000000"
    },
    anaconda : {
        name: "Anaconda",
        description: "Anaconda Description",
        uri: "https://ipfs.io/ipfs/QmZK7pRyT2cKxh6PiLbCEpGUWTa162Q5kAikugf4G5ofoG",
        type: "4",
        deathPoint: "100" + "000000000000000000"
    }
}

const SNAKES = [
    SNAKES_METADATA.dasypeltis,
    SNAKES_METADATA.viper,
    SNAKES_METADATA.python,
    SNAKES_METADATA.anaconda
]

const SNAKE_EGGS_METADATA = {
    dasypeltis : {
        name: "Dasypeltis Egg",
        description: "Dasypeltis Egg Description",
        uri: "https://ipfs.io/ipfs/QmVSjychUYoTv8Yctaaksfs5WcooHBbj2tfXUzr8TNUkBq",
        snakeType: "1",
        price: "2200" + "000000000000000000",
        hatchingPeriod: "86400" //86400 seconds = 1 day
    },
    viper : {
        name: "Viper Egg",
        description: "Viper Egg Description",
        uri: "https://ipfs.io/ipfs/QmS7HAGsF2PCero8FiD785AHoonTJ1AtjcrtTMKt4An9zf",
        snakeType: "2",
        price: "10000" + "000000000000000000",
        hatchingPeriod: "259200" //259200 seconds = 3 days
    },
    python : {
        name: "Python Egg",
        description: "Python Egg Description",
        uri: "https://ipfs.io/ipfs/QmTUnQTH9dzF8e1ECRF8n7YfcXvzDCgZwNhZdYRJbGMNfD",
        snakeType: "3",
        price: "100000" + "000000000000000000",
        hatchingPeriod: "604800" //604800 seconds = 7 days
    },
    anaconda : {
        name: "Anaconda Egg",
        description: "Anaconda Egg Description",
        uri: "https://ipfs.io/ipfs/QmPcgBHP2HsfTXQwMEJda5pb2NzCBXapQsTFpXAN6MgRJK",
        snakeType: "4",
        price: "500000" + "000000000000000000",
        hatchingPeriod: "1209600" //1209600 seconds = 14 days
    }
}

const EGGS = [
    SNAKE_EGGS_METADATA.dasypeltis,
    SNAKE_EGGS_METADATA.viper,
    SNAKE_EGGS_METADATA.python,
    SNAKE_EGGS_METADATA.anaconda
]

const USERS = [
]

const VESTING_AMOUNTS = [
]

module.exports = {
    USERS,
    VESTING_AMOUNTS,
    ARTIFACTS,
    EGGS,
    SNAKES,
    PROVIDERS,
    OZ: openZeppelinHelper.constants
}