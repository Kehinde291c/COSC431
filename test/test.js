const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("KehindeDAO", function () {
    let KehindeDAO;
    let Token;
    let dao;
    let token;
    let chairperson;
    let member1;
    let member2;

    beforeEach(async function () {
        [chairperson, member1, member2] = await ethers.getSigners();

        Token = await ethers.getContractFactory("MockERC20");
        token = await Token.deploy("Governance Token", "GT", 1000);
        await token.deployed();

        await token.transfer(member1.address, 100);
        await token.transfer(member2.address, 100);

        KehindeDAO = await ethers.getContractFactory("KehindeDAO");
        dao = await KehindeDAO.deploy(token.address, [member1.address, member2.address]);
        await dao.deployed();
    });

    it("should allow members to create proposals", async function () {
        await dao.connect(member1).createProposal("Proposal 1", 60);
        const proposal = await dao.proposals(0);
        expect(proposal.description).to.equal("Proposal 1");
    });

    it("should allow members to vote on proposals", async function () {
        await dao.connect(member1).createProposal("Proposal 1", 60);
        await dao.connect(member1).vote(0);
        const proposal = await dao.proposals(0);
        expect(proposal.voteCount).to.equal(100);
    });

    it("should allow the chairperson to execute proposals", async function () {
        await dao.connect(member1).createProposal("Proposal 1", 1);
        await dao.connect(member2).vote(0);
        await ethers.provider.send("evm_increaseTime", [60]);
        await ethers.provider.send("evm_mine");

        await dao.connect(chairperson).executeProposal(0);
        const proposal = await dao.proposals(0);
        expect(proposal.executed).to.be.true;
    });

    it("should not allow non-members to create proposals", async function () {
        await expect(dao.connect(chairperson).createProposal("Proposal 1", 60)).to.be.revertedWith("Not a member");
    });

    it("should not allow non-members to vote", async function () {
        await dao.connect(member1).createProposal("Proposal 1", 60);
        await expect(dao.connect(chairperson).vote(0)).to.be.revertedWith("Not a member");
    });

    it("should not allow non-chairperson to execute proposals", async function () {
        await dao.connect(member1).createProposal("Proposal 1", 60);
        await dao.connect(member2).vote(0);
        await ethers.provider.send("evm_increaseTime", [60]);
        await ethers.provider.send("evm_mine");

        await expect(dao.connect(member1).executeProposal(0)).to.be.revertedWith("Not the chairperson");
    });

    it("should add and remove members", async function () {
        await dao.connect(chairperson).addMember(chairperson.address);
        expect(await dao.members(chairperson.address)).to.be.true;

        await dao.connect(chairperson).removeMember(chairperson.address);
        expect(await dao.members(chairperson.address)).to.be.false;
    });
});