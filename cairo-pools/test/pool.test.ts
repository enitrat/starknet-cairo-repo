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
  let aToken: StarknetContract;
  let ERC20Factory: StarknetContractFactory;
  let testToken: StarknetContract;
  let account: Account;
  let secondAccount: Account;
  let accountAddress: string;
  let secondAddress: string;

  before(async () => {
    poolContractFactory = await starknet.getContractFactory(
      "./contracts/src/Pool"
    );
    ATokenFactory = await starknet.getContractFactory("./contracts/src/AToken");
    ERC20Factory = await starknet.getContractFactory("./contracts/src/ERC20");

    console.log("deploying");
    poolContract = await poolContractFactory.deploy({ provider: 0 });
    console.log("Pool deployed at" + poolContract.address);
    account = await starknet.deployAccount("OpenZeppelin");
    accountAddress = account.starknetContract.address;

    secondAccount = await starknet.deployAccount("OpenZeppelin");
    secondAddress = account.starknetContract.address;

    console.log("Account deployed at deployed at" + accountAddress);

    //Deploy erc20 first
    testToken = await ERC20Factory.deploy({
      name: 1415934836,
      symbol: 5526356,
      decimals: 18,
      initial_supply: bnToUint256(1000),
      recipient: accountAddress,
    });
    console.log("erc20 contract deployed at" + testToken.address);

    //Deploy aToken
    aToken = await ATokenFactory.deploy({
      name: 418027762548,
      symbol: 1632916308,
      decimals: 18,
      initial_supply: bnToUint256(0),
      recipient: poolContract.address,
      owner: poolContract.address,
      underlying: testToken.address,
    });
    console.log("aToken contract deployed at" + aToken.address);
  });

  it("Should init reserve", async () => {
    await account.invoke(poolContract, "init_reserve", {
      asset: testToken.address,
      aToken_address: aToken.address,
    });

    let reserve = await poolContract
      .call("get_reserve", {
        asset: testToken.address,
      })
      .then((res) => res.reserve);

    expect(reserve.aToken_address.toString()).equal(
      number.toBN(aToken.address).toString()
    );
  });

  it("Should deposit supply", async () => {
    //Approve token for poolContract
    await account.invoke(testToken, "approve", {
      spender: poolContract.address,
      amount: bnToUint256(100),
    });

    //Supply assets
    await account.invoke(poolContract, "supply", {
      asset: testToken.address,
      amount: bnToUint256(100),
      on_behalf_of: accountAddress,
      referral_code: 0,
    });

    //900 collateral remaining in account
    let userTokens = await testToken
      .call("balanceOf", {
        account: accountAddress,
      })
      .then((res) => res.balance);
    expect(userTokens.low).equal(900n);

    //account owns 100 aToken
    let useraTokens = await aToken
      .call("balanceOf", {
        account: accountAddress,
      })
      .then((res) => res.balance);
    expect(useraTokens.low).equal(100n);

    //aToken_address owns 100 collateral tokens
    let poolCollat = await testToken
      .call("balanceOf", {
        account: aToken.address,
      })
      .then((res) => res.balance);
    expect(poolCollat.low).equal(100n);
  });

  it("Should fail withdrawing more than balance tokens", async () => {
    //Before withdrawing, need to give allowance to AToken contract to move
    try {
      account.invoke(poolContract, "withdraw", {
        asset: testToken.address,
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
      asset: testToken.address,
      amount: bnToUint256(50),
      to: accountAddress,
    });

    //Account back to 950n erc20
    const userTokens = await testToken
      .call("balanceOf", {
        account: accountAddress,
      })
      .then((res) => res.balance);
    expect(userTokens.low).equal(950n);

    //account owns 50 aToken (burnt)
    let useraTokens = await aToken
      .call("balanceOf", {
        account: accountAddress,
      })
      .then((res) => res.balance);
    expect(useraTokens.low).equal(50n);

    //aToken_address back to 50 erc20 (50 transfered to account)
    let poolCollat = await testToken
      .call("balanceOf", {
        account: aToken.address,
      })
      .then((res) => res.balance);
    expect(poolCollat.low).equal(50n);
  });

  it("Should borrow tokens", async () => {
    //Before withdrawing, need to give allowance to AToken contract to move

    await account.invoke(poolContract, "borrow", {
      asset: testToken.address,
      amount: bnToUint256(10),
      interest_rate_mode: 0,
      referral_code: 0,
      on_behalf_of: accountAddress,
    });

    //Account now has 60 erc20
    const userTokens = await testToken
      .call("balanceOf", {
        account: accountAddress,
      })
      .then((res) => res.balance);
    expect(userTokens.low).equal(960n);

    //aToken_address has 40 erc20 (10 more transfered to account)
    let poolCollat = await testToken
      .call("balanceOf", {
        account: aToken.address,
      })
      .then((res) => res.balance);
    expect(poolCollat.low).equal(40n);
  });

  it("Should repay tokens", async () => {
    //Before withdrawing, need to give allowance to AToken contract to move

    await account.invoke(testToken, "approve", {
      spender: poolContract.address,
      amount: bnToUint256(10),
    });

    await account.invoke(poolContract, "repay", {
      asset: testToken.address,
      amount: bnToUint256(10),
      interest_rate_mode: 0,
      on_behalf_of: accountAddress,
    });

    //Account now has 950 erc20
    const userTokens = await testToken
      .call("balanceOf", {
        account: accountAddress,
      })
      .then((res) => res.balance);
    expect(userTokens.low).equal(950n);

    //aToken_address has 50 erc20 (10 more transfered to account)
    let poolCollat = await testToken
      .call("balanceOf", {
        account: aToken.address,
      })
      .then((res) => res.balance);
    expect(poolCollat.low).equal(50n);
  });
});
