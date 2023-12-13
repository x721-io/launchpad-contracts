require("@nomicfoundation/hardhat-toolbox");
require('dotenv').config();
/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.7.6",
  settings: {
    optimizer: {
      enabled: true,
      runs: 1000,
    },
  },
  paths: {
    sources: "./contracts/new-version"
  },
  networks: {
    bscMainnet: {
      url: "https://bsc-dataseed.binance.org/",
      accounts: [process.env.PRIVATE_KEY]
    },
    bscTestnet: {
      url: "https://bsc-testnet.publicnode.com",
      accounts: [process.env.PRIVATE_KEY]
    },
    ethereumGoerli: {
      url: "https://goerli.infura.io/v3/9aa3d95b3bc440fa88ea12eaa4456161",
      accounts: [process.env.PRIVATE_KEY]
    },
    ethereumMainnet: {
      url: "https://rpc.mevblocker.io",
      accounts: [process.env.PRIVATE_KEY]
    },
    u2uTestnet: {
      url: "https://rpc-nebulas-testnet.uniultra.xyz",
      accounts: [process.env.PRIVATE_KEY],
      gas: 8000000
    }
  },
  etherscan: {
    apiKey: "TQDQYCU7B2GRP5Z11A5Z55WWQZHKRUEQPB",
    // apiKey: "Y5PR5VRPI53YEDAJZYWX8CWSA3SHIIIAPG",
  },
};
