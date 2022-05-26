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

    //Deploy erc20 first
    erc20Contract = await ERC20Factory.deploy({
      name: 1415934836,
      symbol: 5526356,
      decimals: 18,
      initial_supply: bnToUint256(1000),
      recipient: accountAddress,
    });
    console.log("erc20 contract deployed at" + erc20Contract.address);

    //Deploy aToken
    aTokenContract = await ATokenFactory.deploy({
      name: 418027762548,
      symbol: 1632916308,
      decimals: 18,
      initial_supply: bnToUint256(0),
      recipient: poolContract.address,
      owner: poolContract.address,
      underlying: erc20Contract.address,
    });
    console.log("aToken contract deployed at" + aTokenContract.address);
  });

  it("Should init reserve", async () => {
    await account.invoke(poolContract, "init_reserve", {
      asset: erc20Contract.address,
      aTokenAddress: aTokenContract.address,
    });

    let reserve = await poolContract
      .call("get_reserve", {
        asset: erc20Contract.address,
      })
      .then((res) => res.reserve);

    expect(reserve.aTokenAddress.toString()).equal(
      number.toBN(aTokenContract.address).toString()
    );
  });

  it("Should deposit supply", async () => {
    //account
    let erc20Balance = await erc20Contract
      .call("balanceOf", {
        account: accountAddress,
      })
      .then((res) => res.balance);
    expect(erc20Balance.low).equal(1000n);

    //account atoken balance
    let aTokenBalance = await aTokenContract
      .call("balanceOf", {
        account: accountAddress,
      })
      .then((res) => res.balance);
    expect(aTokenBalance.low).equal(0n);

    //Approve token for poolContract
    await account.invoke(erc20Contract, "approve", {
      spender: poolContract.address,
      amount: bnToUint256(100),
    });
    let remainingAllowance = await erc20Contract
      .call("allowance", {
        owner: accountAddress,
        spender: poolContract.address,
      })
      .then((res) => res.remaining);
    expect(remainingAllowance.low).equal(100n);

    //Supply assets
    await account.invoke(poolContract, "supply", {
      asset: erc20Contract.address,
      amount: bnToUint256(100),
      onBehalfOf: accountAddress,
    });

    //900 collateral remaining in account
    let remainingErc20 = await erc20Contract
      .call("balanceOf", {
        account: accountAddress,
      })
      .then((res) => res.balance);
    expect(remainingErc20.low).equal(900n);

    //account owns 100 aToken
    let newATokens = await aTokenContract
      .call("balanceOf", {
        account: accountAddress,
      })
      .then((res) => res.balance);
    expect(newATokens.low).equal(100n);

    //aTokenAddress owns 100 collateral tokens
    let suppliedUnderlying = await erc20Contract
      .call("balanceOf", {
        account: aTokenContract.address,
      })
      .then((res) => res.balance);
    expect(suppliedUnderlying.low).equal(100n);
  });

  it("Should fail withdrawing more than balance tokens", async () => {
    //Before withdrawing, need to give allowance to AToken contract to move
    try {
      account.invoke(poolContract, "withdraw", {
        asset: erc20Contract.address,
        amount: bnToUint256(200),
        to: accountAddress,
      });
    } catch (e: any) {
      expect(e.message.includes("Withdraw amount exceeds balance"));
    }
  });

  it("Should withdraw tokens to caller address", async () => {
    //Before withdrawing, need to give allowance to AToken contract to move

    await account.invoke(poolContract, "withdraw", {
      asset: erc20Contract.address,
      amount: bnToUint256(100),
      to: accountAddress,
    });

    //Account back to 1000 erc20
    const accountErc20 = await erc20Contract
      .call("balanceOf", {
        account: accountAddress,
      })
      .then((res) => res.balance);
    expect(accountErc20.low).equal(1000n);

    //account owns 0 aToken (burnt)
    let accountATokens = await aTokenContract
      .call("balanceOf", {
        account: accountAddress,
      })
      .then((res) => res.balance);
    expect(accountATokens.low).equal(0n);

    //aTokenAddress back to 0 erc20 (transfered to account)
    let newATokens = await erc20Contract
      .call("balanceOf", {
        account: aTokenContract.address,
      })
      .then((res) => res.balance);
    expect(newATokens.low).equal(0n);
  });
});
