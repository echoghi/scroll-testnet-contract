import * as dotenv from 'dotenv';

import { HardhatUserConfig } from 'hardhat/config';
import '@nomicfoundation/hardhat-toolbox';

dotenv.config();

const config: HardhatUserConfig = {
  solidity: {
    version: '0.8.17',
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
  networks: {
    scrollAlpha: {
      url: process.env.SCROLL_TESTNET_URL || '',
      accounts: process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : []
    }
  },
  etherscan: {
    apiKey: {
      scrollAlpha: process.env.BLOCKSCOUT_KEY || ''
    },
    customChains: [
      {
        network: 'scrollAlpha',
        chainId: 534353,
        urls: {
          apiURL: 'https://blockscout.scroll.io/api',
          browserURL: 'https://blockscout.scroll.io/'
        }
      }
    ]
  }
};

export default config;
