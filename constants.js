const openZeppelinHelper = require('@openzeppelin/test-helpers');

const PROVIDERS = {
    BSC_MAINNET: `https://bsc-dataseed.binance.org/`,
    BSC_TESTNET: `https://data-seed-prebsc-1-s1.binance.org:8545/`
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
    },
    pixelFreeze: {
        id: 11,
        name: "Pixel Freeze",
        description: "When applied, the pixel stops being fading and becomes static. From the moment of activation, it is valid for all games (Daily GP) available to this character within one game day.",
        uri: "https://bafybeiapahxniqz34rpjhntvjefrvvi3gm6345jiyyakosbkfw4tm3ovze.ipfs.infura-ipfs.io/",
        price: "40000000000000000000",
        amount: 70000
    },
    bombardo: {
        id: 12,
        name: "Bombardo",
        description: "After being used in the arena, all bombs disappear. From the moment of activation, it is valid for all games (Daily GP) available to this character within one game day.",
        uri: "https://bafybeidspdwhg3j6sudjxrm32tzbat2aehzj2udgsfpkakmg7lzgjeks2q.ipfs.infura-ipfs.io/",
        price: "45000000000000000000",
        amount: 40000
    },
    scaleArmor: {
        id: 13,
        name: "Scale Armor",
        description: "Artifact reduces damage on impact by half. From the moment of activation, it is valid for all games (Daily GP) available to this character within one game day.",
        uri: "https://bafybeiejijzbnf7ay54l3d7rlbpeulgrzcpalwcirjpnrknuh5tdlkpcnu.ipfs.infura-ipfs.io/",
        price: "67000000000000000000",
        amount: 60000
    },
    speedBuff: {
        id: 14,
        name: "Speed Buff Prof",
        description: "Limits the maximum speed to 10 lvl. From the moment of activation, it is valid for all games (Daily GP) available to this character within one game day.",
        uri: "https://bafybeiauqhpqoj527hbooylra6xau6bqcfrk72mhhhb3lfqhycgky2klem.ipfs.infura-ipfs.io/",
        price: "79000000000000000000",
        amount: 25000
    },
    speedNoober: {
        id: 15,
        name: "Speed Noober",
        description: "Limits the maximum speed to 5 lvl. From the moment of activation, it is valid for all games (Daily GP) available to this character within one game day.",
        uri: "https://bafybeifagt55o5vlp5y3tzlt3jfew7ubz2crgqjf3xxwkwvnhlxfg7eoaa.ipfs.infura-ipfs.io/",
        price: "60000000000000000000",
        amount: 30000
    },
    burger: {
        id: 16,
        name: "Burger",
        description: "Increases the eaten pixel ratio by х2. For example, if your ratio was 1 to 1, it will be 1 to 2. From the moment of activation, it is valid for all games (Daily GP) available to this character within one game day.",
        uri: "https://bafybeigpg3d6y7ppk7cjd5tvvwsp7yvzmv57xrgcwif6vreyle6akwsfly.ipfs.infura-ipfs.io/",
        price: "110000000000000000000",
        amount: 25000
    },
    fiveGames: {
        id: 17,
        name: "+ 5 GP",
        description: "Gives +5 game sessions to the character until the end of the current game day. If you don’t use your games, they disappear next day.",
        uri: "https://bafybeihxc32mw2r65llhvjbdikdm3cta44wtrawuexkwxtnup6gvyni75a.ipfs.infura-ipfs.io/",
        price: "180000000000000000000",
        amount: 20000
    },
    tenGames: {
        id: 18,
        name: "+ 10 GP",
        description: "Gives +10 game sessions to the character until the end of the current game day. If you don’t use your games, they disappear next day.",
        uri: "https://bafybeihtmyal3ejo3eh2pgqe75ewyxwb7qbenefm2naa6jn4tmmgzdxfoq.ipfs.infura-ipfs.io/",
        price: "400000000000000000000",
        amount: 15000
    },
    spasm: {
        id: 19,
        name: "Spasm",
        description: "The tail of a snake grows twice as slowly. It will be easier for you to control your snake. From the moment of activation, it is valid for all games (Daily GP) available to this character within one game day.",
        uri: "https://bafybeibhb57we54db6m65a26l6nlkwkw3bfutpptehkiy442j5grrgq26m.ipfs.infura-ipfs.io/",
        price: "30000000000000000000",
        amount: 55000
    },
    mana: {
        id: 20,
        name: "Mana",
        description: "SNK collected in the game arena are immediately credited to the character's TVL. This means that you will be able to withdraw them.From the moment of activation, it is valid for all games (Daily GP) available to this character within one game day.",
        uri: "https://bafybeif5reodsts6vg2kym267jlnfslnpofstvoizky4rd374sgnidljva.ipfs.infura-ipfs.io/",
        price: "83000000000000000000",
        amount: 33000
    },
    digger: {
        id: 21,
        name: "Digger",
        description: "Transfers the entire Game Balance to the character's TVL. This means that you will be able to withdraw it.Disposable Artifact. Can be applied multiple times.",
        uri: "https://bafybeiheck6ngj7fof5chswfxxxvghxgefm64zophwcisrzy4q4f4ojsnu.ipfs.infura-ipfs.io/",
        price: "1200000000000000000000",
        amount: 33000
    },
    joker: {
        id: 22,
        name: "Joker",
        description: "SNK collected in the gaming arena are immediately credited to the connected wallet. From the moment of activation, it is valid for all games (Daily GP) available to this character within one game day.",
        uri: "https://bafybeiabqyjwerjpj37s5vz6fikl6v4h7eptsutpm5vt44nyn5z2jru76a.ipfs.infura-ipfs.io/",
        price: "110000000000000000000",
        amount: 33000
    },
    sniper: {
        id: 23,
        name: "Sniper",
        description: "Three static pixels appear on the arena at once. A new pixel appears after eating the previous one. This means that you will hunt pixels faster and earn more. From the moment of activation, it is valid for all games (Daily GP) available to this character within one game day.",
        uri: "https://bafybeidtj6e4ez42m74ylhzg4ptllztxhlupxgpapfggfi5jhrehegapwy.ipfs.infura-ipfs.io/",
        price: "60000000000000000000",
        amount: 15000
    },
    partnerDao: {
        id: 24,
        name: "Partner DAO",
        description: "",
        uri: "https://bafybeidq7nwjhlbkcd6a6b2xckfysiyhuxf4dsyrcsy6f7lx3zqqxo2nda.ipfs.infura-ipfs.io/",
        price: "15000000000000000000000",
        amount: 50000
    },
    masterDao: {
        id: 25,
        name: "Master DAO",
        description: "",
        uri: "https://bafybeidzdistkjdkr3ecbjpobddgstrzvcsbbcz25t2xshpmza4dh4mzl4.ipfs.infura-ipfs.io/",
        price: "150000000000000000000000",
        amount: 5000
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
    ARTIFACTS_METADATA.snakeTime,
    ARTIFACTS_METADATA.pixelFreeze,
    ARTIFACTS_METADATA.bombardo,
    ARTIFACTS_METADATA.scaleArmor,
    ARTIFACTS_METADATA.speedBuff,
    ARTIFACTS_METADATA.speedNoober,
    ARTIFACTS_METADATA.burger,
    ARTIFACTS_METADATA.fiveGames,
    ARTIFACTS_METADATA.tenGames,
    ARTIFACTS_METADATA.spasm,
    ARTIFACTS_METADATA.mana,
    ARTIFACTS_METADATA.digger,
    ARTIFACTS_METADATA.joker,
    ARTIFACTS_METADATA.sniper,
    ARTIFACTS_METADATA.partnerDao,
    ARTIFACTS_METADATA.masterDao
]

const SNAKES_METADATA = {
    dasypeltis : {
        name: "Dasypeltis",
        description: "Dasypeltis Description",
        uri: "https://ipfs.io/ipfs/QmeEcezaPgNGjoJhPmGEPSatqW1GTw4YoWm3cgWFSPvTSt",
        type: "1",
        deathPoint: "22" + "000000000000000000"
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
        deathPoint: "1000" + "000000000000000000"
    },
    anaconda : {
        name: "Anaconda",
        description: "Anaconda Description",
        uri: "https://ipfs.io/ipfs/QmZK7pRyT2cKxh6PiLbCEpGUWTa162Q5kAikugf4G5ofoG",
        type: "4",
        deathPoint: "5000" + "000000000000000000"
    },
    mamba : {
        name: "Black Mamba",
        description: "Black Mamba Description",
        uri: "https://ipfs.io/ipfs/QmboNMaBfPy9HFgCsEtgAJADtZok5pue8xcKGWGsViB74e",
        type: "5",
        deathPoint: "5" + "000000000000000000"
    }
}

const SNAKES = [
    SNAKES_METADATA.dasypeltis,
    SNAKES_METADATA.viper,
    SNAKES_METADATA.python,
    SNAKES_METADATA.anaconda,
    SNAKES_METADATA.mamba
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
    },
    mamba : {
        name: "Black Mamba Egg",
        description: "Black Mamba Egg Description",
        uri: "https://ipfs.io/ipfs/QmYyq2hAzsBvcPvj5qc5fUVe8WtrNSWoGFhXLEghos98oy",
        snakeType: "5",
        price: "99" + "000000000000000000",
        hatchingPeriod: "86400" //86400 seconds = 1 day
    }
}

const EGGS = [
    SNAKE_EGGS_METADATA.dasypeltis,
    SNAKE_EGGS_METADATA.viper,
    SNAKE_EGGS_METADATA.python,
    SNAKE_EGGS_METADATA.anaconda,
    SNAKE_EGGS_METADATA.mamba
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