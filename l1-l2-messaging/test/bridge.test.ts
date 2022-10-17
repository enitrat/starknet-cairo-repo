import { expect } from "chai";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { Contract, ContractFactory, providers, BigNumber } from "ethers";
import hre, { starknet, network, ethers } from "hardhat";
import {
  StarknetContractFactory,
  StarknetContract,
  HttpNetworkConfig,
  Account,
  StringMap,
} from "hardhat/types";
import { number } from "starknet";

describe("Greeter", function () {
  const networkUrl: string = (network.config as HttpNetworkConfig).url;

  let l1user: SignerWithAddress;
  let l1ProxyAdmin: SignerWithAddress;

  let signer: SignerWithAddress;

  //bridge
  let l1Bridge: Contract;

  let l2BridgeFactory: StarknetContractFactory;
  let l2Bridge: StarknetContract;

  let l2BalanceFactory: StarknetContractFactory;
  let l2Balance: StarknetContract;

  let mockStarknetMessagingAddress: string;

  before(async () => {
    mockStarknetMessagingAddress = (
      await starknet.devnet.loadL1MessagingContract(networkUrl)
    ).address;

    [signer, l1user, l1ProxyAdmin] = await ethers.getSigners();

    // factories
    let l1BridgeFactory: ContractFactory;

    l2BridgeFactory = await starknet.getContractFactory(
      "StarknetBridgeExecutor"
    );
    l2Bridge = await l2BridgeFactory.deploy();

    l2BalanceFactory = await starknet.getContractFactory("Balance");
    l2Balance = await l2BalanceFactory.deploy();

    l1BridgeFactory = await ethers.getContractFactory("Executor", signer);
    l1Bridge = await l1BridgeFactory.deploy(
      mockStarknetMessagingAddress,
      l2Bridge.address,
      l2Balance.address
    );
    await l1Bridge.deployed();
  });
  it("Should send increase the counter through the bridge ", async function () {
    const { res: currentBalance } = await l2Balance.call("get_counter");
    console.log(currentBalance);

    const _msg_address = await l1Bridge._messagingContract();
    const _targetContract = (
      await l1Bridge._targetContractAddress()
    ).toString();
    const _l2Bridge = (await l1Bridge._l2Bridge()).toString();

    const exp1 = number.toBN(l1Bridge.address.toString()).toString();
    const exp2 = number.toBN(l2Balance.address).toString();
    const exp3 = number.toBN(l2Bridge.address).toString();

    expect(_msg_address).to.equal(mockStarknetMessagingAddress);
    expect(_targetContract).to.equal(exp2);
    expect(_l2Bridge).to.equal(exp3);
    const txBridge = await l1Bridge.connect(l1user).setCounter(3);

    const blockNum = txBridge.blockNumber;

    const flushL1Response = await starknet.devnet.flush();
    const flushL1Messages = flushL1Response.consumed_messages.from_l1;

    const { res } = await l2Balance.call("get_counter");
    expect(res).to.equal(3n);
  });
});
