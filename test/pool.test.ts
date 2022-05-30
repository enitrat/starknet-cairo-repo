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

describe("Aave pool test", async () => {
  let poolContractFactory: StarknetContractFactory;
  let poolContract: StarknetContract;
  let ATokenFactory: StarknetContractFactory;
  let aTokenContract: StarknetContract;
  let ERC20Factory: StarknetContractFactory;
  let tokenTest1: StarknetContract;
  let account: Account;
  let secondAccount:Account
  let accountAddress: string;
  let secondAddress:string;

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
    
    secondAccount = await starknet.deployAccount("OpenZeppelin");
    secondAddress = account.starknetContract.address;

    console.log("Account deployed at deployed at" + accountAddress);

    //Deploy erc20 first
    tokenTest1 = await ERC20Factory.deploy({
      name: 1415934836,
      symbol: 5526356,
      decimals: 18,
      initial_supply: bnToUint256(1000),
      recipient: accountAddress,
    });
    console.log("erc20 contract deployed at" + tokenTest1.address);

    //Deploy aToken
    aTokenContract = await ATokenFactory.deploy({
      name: 418027762548,
      symbol: 1632916308,
      decimals: 18,
      initial_supply: bnToUint256(0),
      recipient: poolContract.address,
      owner: poolContract.address,
      underlying: tokenTest1.address,
    });
    console.log("aToken contract deployed at" + aTokenContract.address);
  });

  it("Should init reserve", async () => {
    await account.invoke(poolContract, "init_reserve", {
      asset: tokenTest1.address,
      aTokenAddress: aTokenContract.address,
    });

    let reserve = await poolContract
      .call("get_reserve", {
        asset: tokenTest1.address,
      })
      .then((res) => res.reserve);

    expect(reserve.aTokenAddress.toString()).equal(
      number.toBN(aTokenContract.address).toString()
    );
  });

  it("Should deposit supply", async () => {
    //account
    let erc20Balance = await tokenTest1 
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
    await account.invoke(tokenTest1, "approve", {
      spender: poolContract.address,
      amount: bnToUint256(100),
    });
    let remainingAllowance = await tokenTest1 
      .call("allowance", {
        owner: accountAddress,
        spender: poolContract.address,
      })
      .then((res) => res.remaining);
    expect(remainingAllowance.low).equal(100n);

    //Supply assets
    await account.invoke(poolContract, "supply", {
      asset: tokenTest1.address,
      amount: bnToUint256(100),
      onBehalfOf: accountAddress,
    });

    //900 collateral remaining in account
    let remainingErc20 = await tokenTest1 
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
    let suppliedUnderlying = await tokenTest1 
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
        asset: tokenTest1.address,
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
      asset: tokenTest1.address,
      amount: bnToUint256(50),
      to: accountAddress,
    });

    //Account back to 950n erc20
    const accountErc20 = await tokenTest1 
      .call("balanceOf", {
        account: accountAddress,
      })
      .then((res) => res.balance);
    expect(accountErc20.low).equal(950n);

    //account owns 50 aToken (burnt)
    let accountATokens = await aTokenContract
      .call("balanceOf", {
        account: accountAddress,
      })
      .then((res) => res.balance);
    expect(accountATokens.low).equal(50n);

    //aTokenAddress back to 50 erc20 (50 transfered to account)
    let newATokens = await tokenTest1 
      .call("balanceOf", {
        account: aTokenContract.address,
      })
      .then((res) => res.balance);
    expect(newATokens.low).equal(50n);
  });

  it("Should borrow tokens", async () => {
    //Before withdrawing, need to give allowance to AToken contract to move

    await account.invoke(poolContract, "borrow", {
      asset: tokenTest1.address,
      amount: bnToUint256(10),
      onBehalfOf: accountAddress,
    });

    //Account now has 60 erc20
    const accountErc20 = await tokenTest1 
      .call("balanceOf", {
        account: accountAddress,
      })
      .then((res) => res.balance);
    expect(accountErc20.low).equal(960n);

    //aTokenAddress has 40 erc20 (10 more transfered to account)
    let newATokens = await tokenTest1 
      .call("balanceOf", {
        account: aTokenContract.address,
      })
      .then((res) => res.balance);
    expect(newATokens.low).equal(40n);
  });

  it("Should repay tokens", async () => {
    //Before withdrawing, need to give allowance to AToken contract to move

    await account.invoke(tokenTest1, "approve", {
      spender: poolContract.address,
      amount: bnToUint256(10),
    });

    await account.invoke(poolContract, "repay", {
      asset: tokenTest1.address,
      amount: bnToUint256(10),
      onBehalfOf: accountAddress,
    });

    //Account now has 950 erc20
    const accountErc20 = await tokenTest1 
      .call("balanceOf", {
        account: accountAddress,
      })
      .then((res) => res.balance);
    expect(accountErc20.low).equal(950n);

    //aTokenAddress has 50 erc20 (10 more transfered to account)
    let newATokens = await tokenTest1 
      .call("balanceOf", {
        account: aTokenContract.address,
      })
      .then((res) => res.balance);
    expect(newATokens.low).equal(50n);
  });
});
