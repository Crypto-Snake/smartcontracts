const HDWalletProvider = require('@truffle/hdwallet-provider');
const constants = require('./constants.js');

module.exports = {
    networks: {
        bscmainnet: {
            provider: () => new HDWalletProvider(constants.SNK_OWNER_PRIVATE_KEY, constants.PROVIDERS.BSC_MAINNET),
            network_id: 56,
            confirmations: 3,
            timeoutBlocks: 200,
            skipDryRun: true,
            gas: 7900000,
            gasPrice: 10000000000
        },
        bsctestnet: {
            provider: () => new HDWalletProvider(constants.SNK_OWNER_PRIVATE_KEY, constants.PROVIDERS.BSC_TESTNET),
            network_id: 97,
            timeoutBlocks: 200,
            skipDryRun: true,
            gas: 7900000,
            gasPrice: 20000000000
        },
        develop: {
            host: "127.0.0.1", // Localhost (default: none)
            port: 8545, // Standard Ethereum port (default: none)
            network_id: "*", // Any network (default: none)
            gasPrice: 0x1,
            gas: 0x1fffffffffffff,
            defaultEtherBalance: constants.OZ.MAX_UINT256.toString(),
        },
    },

    // Set default mocha options here, use special reporters etc.
    mocha: {
        // timeout: 100000
    },

    // Configure your compilers
    compilers: {
        solc: {
            version: "0.8.9",
            settings: {
                optimizer: {
                    enabled: true,
                    runs: 200,
                }
            },
        },
    },

    // Truffle DB is currently disabled by default; to enable it, change enabled: false to enabled: true
    //
    // Note: if you migrated your contracts prior to enabling this field in your Truffle project and want
    // those previously migrated contracts available in the .db directory, you will need to run the following:
    // $ truffle migrate --reset --compile-all

    db: {
        enabled: false,
    },
};