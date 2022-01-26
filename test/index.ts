import { expect } from "chai";
import { Contract } from "ethers";
import { ethers } from "hardhat";
import { BigNumber } from "@ethersproject/bignumber";

export const ether = (amount: number | string): BigNumber => {
  const weiString = ethers.utils.parseEther(amount.toString());
  return BigNumber.from(weiString);
};

describe("Staking", function () {
  let mockToken: Contract;
  let stakingSC: Contract;
  let signers: any;

  beforeEach(async () => {
    signers = await ethers.getSigners();

    const Token = await ethers.getContractFactory("Token", signers[0]);
    mockToken = await Token.deploy();
    await mockToken.deployed();

    const Staking = await ethers.getContractFactory("Staking", signers[0]);
    stakingSC = await Staking.deploy(mockToken.address);
    await stakingSC.deployed();

    await mockToken.connect(signers[0]).mint(signers[0].address, ether(1000));
  });

  describe("Staking & Distribution", async () => {
    it("Staking", async () => {
      await mockToken.connect(signers[0]).approve(stakingSC.address, ether(100));
      await stakingSC.connect(signers[0]).stake(ether(100));
      const afterBalance = await mockToken.balanceOf(signers[0].address);
      expect(afterBalance).to.eq(ether(900));
    });

    it("Getting Reward", async () => {
      await mockToken.connect(signers[0]).approve(stakingSC.address, ether(150));
      await stakingSC.connect(signers[0]).stake(ether(100));

      let reward = await stakingSC.getReward(signers[0].address);
      expect(reward).to.eq(0);

      await stakingSC.connect(signers[0]).distribute(ether(50));
      reward = await stakingSC.getReward(signers[0].address);
      expect(reward).to.eq(ether(50));
    });

    it("Distribution", async () => {
      await mockToken.connect(signers[0]).approve(stakingSC.address, ether(150));
      await stakingSC.connect(signers[0]).stake(ether(100));
      await stakingSC.connect(signers[0]).distribute(ether(50));

      const lastRewardRate = await stakingSC.lastRewardRate();
      expect(lastRewardRate).to.eq(BigNumber.from("5000"));
    });

    it("Unstake", async () => {
      await mockToken.connect(signers[0]).approve(stakingSC.address, ether(150));
      await stakingSC.connect(signers[0]).stake(ether(100));
      await stakingSC.connect(signers[0]).distribute(ether(50));

      await stakingSC.connect(signers[0]).unstake(ether(50));
      let afterUnstakeBalance = await stakingSC.stakedBalance(
        signers[0].address
      );
      expect(afterUnstakeBalance).to.eq(ether(50));

      await stakingSC.connect(signers[0]).unstakeAll();
      afterUnstakeBalance = await stakingSC.stakedBalance(signers[0].address);
      expect(afterUnstakeBalance).to.eq(ether(0));
    });
  });
});
