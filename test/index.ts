import { expect } from "chai";
import { ethers } from "hardhat";

describe("Staking", function () {
  it("Should return the new greeting once it's changed", async function () {
    const Staking = await ethers.getContractFactory("Staking");
    const stakingSC = await Staking.deploy("Hello, world!");
    await stakingSC.deployed();

    expect(await stakingSC.greet()).to.equal("Hello, world!");
  });
});
