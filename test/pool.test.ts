import {
  StarknetContract,
  StarknetContractFactory,
} from "@shardlabs/starknet-hardhat-plugin/dist/src/types";
import { expect } from "chai";
import { BigNumber, BigNumberish } from "ethers";
import { starknet } from "hardhat";
import { Account } from "hardhat/types";
import { number } from "starknet";
import { bnToUint256, Uint256 } from "starknet/dist/utils/uint256";

interface ReserveData {
  id: BigInt;
  aTokenAddress: BigInt;
  supply: Uint256;
}

describe("Aave pool test", async () => {
  let poolContractFactory: StarknetContractFactory;
  let poolContract: StarknetContract;
  let account: Account;
  let accountAddress: string;

  before(async () => {
    poolContractFactory = await starknet.getContractFactory("Pool");
    console.log("deploying");
    poolContract = await poolContractFactory.deploy({});
    console.log("Pool deployed at" + poolContract.address);

    account = await starknet.deployAccount("OpenZeppelin");
    accountAddress = number.toBN(account.starknetContract.address).toString();
  });

  it("Should fail withdrawing tokens with null balances", async () => {
    try {
      await account.invoke(poolContract, "withdraw", {
        asset: 1,
        amount: bnToUint256(100),
        to: accountAddress,
      });
    } catch (err: any) {
      console.log(err);
      console.log("-------");
      console.log(err.message);

      expect(err.message).to.contain("Got");
    }

    // const { reserve: newReserve } = await poolContract.call("get_reserve", {
    //   asset: 1,
    // });
    // expect(newReserve.supply.low).equal(0n);

    // const { balance: newBalance } = await poolContract.call("get_balance", {
    //   address: accountAddress,
    //   asset: 1,
    // });

    // expect(newBalance.low).equal(0n);
  });

  it("Should deposit supply", async () => {
    const { reserve: prevReserve } = await poolContract.call("get_reserve", {
      asset: 1,
    });
    const { balance: prevBalance } = await poolContract.call("get_balance", {
      address: accountAddress,
      asset: 1,
    });
    console.log(prevReserve);
    console.log(prevBalance);

    expect(prevBalance.low).equal(0n);

    expect(prevReserve.supply.low).equal(0n);

    await account.invoke(poolContract, "supply", {
      asset: 1,
      amount: bnToUint256(100),
      onBehalfOf: accountAddress,
    });

    const { reserve: newReserve } = await poolContract.call("get_reserve", {
      asset: 1,
    });
    expect(newReserve.supply.low).equal(100n);

    const { balance: newBalance } = await poolContract.call("get_balance", {
      address: accountAddress,
      asset: 1,
    });

    expect(newBalance.low).equal(100n);
  });

  it("Should withdraw tokens", async () => {
    await account.invoke(poolContract, "withdraw", {
      asset: 1,
      amount: bnToUint256(100),
      to: accountAddress,
    });

    const { reserve: newReserve } = await poolContract.call("get_reserve", {
      asset: 1,
    });
    expect(newReserve.supply.low).equal(0n);

    const { balance: newBalance } = await poolContract.call("get_balance", {
      address: accountAddress,
      asset: 1,
    });

    expect(newBalance.low).equal(0n);
  });
});
