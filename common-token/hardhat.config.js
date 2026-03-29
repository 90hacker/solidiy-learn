require('dotenv').config();
require('@nomicfoundation/hardhat-toolbox');

module.exports = {
  solidity: {
    compilers: [
      { 
        version: '0.8.31',
        settings: { optimizer: { enabled: true, runs: 200 } }
      }
    ]
  },
  paths: {
    sources: './contracts',
    tests: './test',
    cache: './cache',
    artifacts: './artifacts'
  },
  networks: {
    hardhat: {},
    // BSC mainnet (use --network bsc)
    bsc: {
      url: process.env.BSC_RPC_URL || process.env.RPC_URL || 'https://bsc-rpc.publicnode.com/',
      chainId: 56,
      gasPrice: 'auto',
      accounts: process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : []
    },
    // BSC testnet (use --network bscTestnet)
    bscTestnet: {
      url: process.env.BSC_TESTNET_RPC_URL || process.env.RPC_URL || 'https://data-seed-prebsc-1-s1.binance.org:8545/',
      chainId: 97,
      gasPrice: 'auto',
      accounts: process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : []
    }
  },
  etherscan: {
    // Use unified Etherscan V2 API key. Set ETHERSCAN_API_KEY to your Etherscan or BscScan API key.
    // Fallback to BSCSCAN_API_KEY if ETHERSCAN_API_KEY is not set.
    apiKey: process.env.ETHERSCAN_API_KEY || process.env.BSCSCAN_API_KEY || '',
    // register BSC as a custom chain so verify plugin knows the correct API endpoints
    customChains: [
      {
        network: 'bsc',
        chainId: 56,
        urls: {
          apiURL: 'https://api.bscscan.com/api',
          browserURL: 'https://bscscan.com'
        }
      },
      {
        network: 'bscTestnet',
        chainId: 97,
        urls: {
          apiURL: 'https://api-testnet.bscscan.com/api',
          browserURL: 'https://testnet.bscscan.com'
        }
      }
    ],
    // Optional: enable Sourcify verification as fallback
    sourcify: {
      enabled: false,
      apiUrl: 'https://sourcify.dev/server'
    }
  }
};
