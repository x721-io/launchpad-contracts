require("@nomicfoundation/hardhat-toolbox");
require('dotenv').config();
/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    compilers: [
      {
        version: "0.7.6",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
    ],
  },
  // paths: {
  //   sources: "./contracts/new-version"
  // },
  networks: {
    bscMainnet: {
      url: "https://bsc-dataseed.binance.org/",
      accounts: [process.env.PRIVATE_KEY_1]
    },
    bscTestnet: {
      url: "https://bsc-testnet.publicnode.com",
      accounts: [process.env.PRIVATE_KEY_1]
    },
    ethereumGoerli: {
      url: "https://goerli.infura.io/v3/9aa3d95b3bc440fa88ea12eaa4456161",
      accounts: [process.env.PRIVATE_KEY_1]
    },
    ethereumMainnet: {
      url: "https://rpc.mevblocker.io",
      accounts: [process.env.PRIVATE_KEY_1]
    },
    u2uTestnet: {
      url: "https://rpc-nebulas-testnet.uniultra.xyz",
      accounts: [process.env.PRIVATE_KEY_1],
      gas: 8000000
    }
  },
  etherscan: {
    apiKey: {
      u2uTestnet: "hi"
    },
    customChains: [
      {
        network: "u2uTestnet",
        chainId: 2484,
        urls: {
          apiURL: "https://testnet.u2uscan.xyz/api",
          browserURL: "https://testnet.u2uscan.xyz/"
        }
      }
    ]
  },
};
