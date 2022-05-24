import * as dotenv from "dotenv";

import { HardhatUserConfig } from "hardhat/types";
import "@shardlabs/starknet-hardhat-plugin";
import "@nomiclabs/hardhat-ethers";

dotenv.config();

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
const config: HardhatUserConfig = {
  solidity: "0.8.4",
  starknet: {
    // dockerizedVersion: "0.8.1", // alternatively choose one of the two venv options below
    // uses (my-venv) defined by `python -m venv path/to/my-venv`
    venv: "~/cairo_venv",

    // uses the currently active Python environment (hopefully with available Starknet commands!)
    // venv: "active",
    network: "devnet",
    wallets: {
      OpenZeppelin: {
        accountName: "OpenZeppelin",
        modulePath:
          "starkware.starknet.wallets.open_zeppelin.OpenZeppelinAccount",
        accountPath: "~/.starknet_accounts",
      },
    },
  },
  networks: {
    devnet: {
      url: "http://127.0.0.1:5050",
    },
    integratedDevnet: {
      url: "http://127.0.0.1:5050",
      // venv: "active",
      dockerizedVersion: "0.2.1",
    },
  },
  mocha: {
    timeout: 60000,
  },
};

export default config;
