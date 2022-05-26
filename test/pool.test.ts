import {
  StarknetContract,
  StarknetContractFactory,
} from "@shardlabs/starknet-hardhat-plugin/dist/src/types";
import { expect } from "chai";
import { assert } from "console";
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
  let ATokenFactory: StarknetContractFactory;
  let aTokenContract: StarknetContract;
  let ERC20Factory: StarknetContractFactory;
  let erc20Contract: StarknetContract;
  let account: Account;
  let accountAddress: string;

  before(async () => {
    poolContractFactory = await starknet.getContractFactory(
      "./contracts/src/Pool"
    );
    ATokenFactory = await starknet.getContractFactory("./contracts/src/AToken");
    ERC20Factory = await starknet.getContractFactory("./contracts/src/ERC20");
    console.log("deploying");
    poolContract = await poolContractFactory.deploy({});
    console.log("Pool deployed at" + poolContract.address);
    account = await starknet.deployAccount("OpenZeppelin");
    accountAddress = account.starknetContract.address;
    console.log("Account deployed at deployed at" + accountAddress);
    aTokenContract = await ATokenFactory.deploy({
      name: 418027762548,
      symbol: 1632916308,
      decimals: 18,
      initial_supply: bnToUint256(1000),
      recipient: poolContract.address,
      owner: poolContract.address,
    });
    console.log("aToken contract deployed at" + aTokenContract.address);
    erc20Contract = await ERC20Factory.deploy({
      name: 1415934836,
      symbol: 5526356,
      decimals: 18,
      initial_supply: bnToUint256(1000),
      recipient: accountAddress,
    });
    console.log("erc20 contract deployed at" + erc20Contract.address);
  });

  // it("Should fail withdrawing tokens with null balances", async () => {
  //   try {
  //     await account.invoke(poolContract, "withdraw", {
  //       asset: 1,
  //       amount: bnToUint256(100),
  //       to: accountAddress,
  //     });
  //   } catch (err: any) {
  //     console.log(err);
  //     console.log("-------");
  //     console.log(err.message);

  //     expect(err.message).to.contain("Got");
  //   }

  //   // const { reserve: newReserve } = await poolContract.call("get_reserve", {
  //   //   asset: 1,
  //   // });
  //   // expect(newReserve.supply.low).equal(0n);

  //   // const { balance: newBalance } = await poolContract.call("get_balance", {
  //   //   address: accountAddress,
  //   //   asset: 1,
  //   // });

  //   // expect(newBalance.low).equal(0n);
  // });

  it("Should init reserve", async () => {
    await account.invoke(poolContract, "init_reserve", {
      asset: erc20Contract.address,
      aTokenAddress: aTokenContract.address,
    });

    const { reserve } = await poolContract.call("get_reserve", {
      asset: erc20Contract.address,
    });

    expect(reserve.aTokenAddress.toString()).equal(
      number.toBN(aTokenContract.address).toString()
    );
  });

  it("Should deposit supply", async () => {
    let { balance } = await erc20Contract.call("balanceOf", {
      account: accountAddress,
    });
    expect(balance.low).equal(1000n);

    ({ balance } = await aTokenContract.call("balanceOf", {
      account: accountAddress,
    }));
    expect(balance.low).equal(0n);

    await account.invoke(erc20Contract, "approve", {
      spender: poolContract.address,
      amount: bnToUint256(100),
    });

    const { remaining } = await erc20Contract.call("allowance", {
      owner: accountAddress,
      spender: poolContract.address,
    });
    expect(remaining.low).equal(100n);
    await account.invoke(poolContract, "supply", {
      asset: erc20Contract.address,
      amount: bnToUint256(100),
      onBehalfOf: accountAddress,
    });

    ({ balance } = await erc20Contract.call("balanceOf", {
      account: accountAddress,
    }));
    expect(balance.low).equal(900n);

    ({ balance } = await aTokenContract.call("balanceOf", {
      account: accountAddress,
    }));
    expect(balance.low).equal(0n);

    // it("Should withdraw tokens", async () => {
    //   await account.invoke(poolContract, "withdraw", {
    //     asset: 1,
    //     amount: bnToUint256(100),
    //     to: accountAddress,
    //   });

    //   const { reserve: newReserve } = await poolContract.call("get_reserve", {
    //     asset: 1,
    //   });
    //   expect(newReserve.supply.low).equal(0n);

    //   const { balance: newBalance } = await poolContract.call("get_balance", {
    //     address: accountAddress,
    //     asset: 1,
    //   });

    //   expect(newBalance.low).equal(0n);
  });
});
