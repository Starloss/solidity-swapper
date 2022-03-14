const { expect } = require("chai");
const { parseEther } = require("ethers/lib/utils");
const { ethers, network, waffle, deployments, getNamedAccounts } = require("hardhat");

describe("NFT's Marketplace", () => {
    let Swapper;
    let owner, Alice, Bob;
    
    beforeEach(async () => {
        await deployments.fixture(['Swapper']);
        let {deployer, user1, user2} = await getNamedAccounts();
        owner = await ethers.getSigner(deployer);
        Alice = await ethers.getSigner(user1);
        Bob = await ethers.getSigner(user2);
        Swapper = await ethers.getContract('Swapper', owner);
    });
});
