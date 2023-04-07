# scroll-testnet-contract

A testnet contract to explore development in Scroll's rollup network. This project contains a simple NFT contract

## Prerequisites

- Network setup: https://guide.scroll.io/user-guide/setup

## Deploy with Hardhat

1. If you haven't already, install [nodejs](https://nodejs.org/en/download/) and [yarn](https://classic.yarnpkg.com/lang/en/docs/install).
2. Run `yarn install` to install dependencies.
3. Create a `.env` file following the example `.env.example` in the root directory. Change `PRIVATE_KEY` to your own account private key in the `.env`.
4. Run `yarn compile` to compile the contract.
5. Run `yarn deploy` or `yarn deployLedger` (requires frame wallet) to deploy the contract on the Scroll Alpha Testnet.
6. Run `yarn test` for hardhat tests.
