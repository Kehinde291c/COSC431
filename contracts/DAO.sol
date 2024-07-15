// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract KehindeDAO {
    struct Proposal {
        string description;
        uint voteCount;
        uint endTime;
        bool executed;
    }

    IERC20 public governanceToken;
    address public chairperson;
    Proposal[] public proposals;
    mapping(address => bool) public members;
    mapping(uint => mapping(address => bool)) public votes;

    event ProposalCreated(uint proposalId, string description, uint endTime);
    event Voted(uint proposalId, address voter, uint weight);
    event Executed(uint proposalId);

    modifier onlyMember() {
        require(members[msg.sender], "Not a member");
        _;
    }

    modifier onlyChairperson() {
        require(msg.sender == chairperson, "Not the chairperson");
        _;
    }

    constructor(address tokenAddress, address[] memory initialMembers) {
        governanceToken = IERC20(tokenAddress);
        chairperson = msg.sender;
        for (uint i = 0; i < initialMembers.length; i++) {
            members[initialMembers[i]] = true;
        }
    }

    function createProposal(string memory description, uint duration) public onlyMember {
        uint endTime = block.timestamp + duration;
        proposals.push(Proposal({description: description, voteCount: 0, endTime: endTime, executed: false}));
        emit ProposalCreated(proposals.length - 1, description, endTime);
    }

    function vote(uint proposalId) public onlyMember {
        Proposal storage proposal = proposals[proposalId];
        require(block.timestamp < proposal.endTime, "Voting period ended");
        require(!votes[proposalId][msg.sender], "Already voted");

        uint weight = governanceToken.balanceOf(msg.sender);
        proposal.voteCount += weight;
        votes[proposalId][msg.sender] = true;
        emit Voted(proposalId, msg.sender, weight);
    }

    function executeProposal(uint proposalId) public onlyChairperson {
        Proposal storage proposal = proposals[proposalId];
        require(block.timestamp >= proposal.endTime, "Voting period not ended");
        require(!proposal.executed, "Already executed");

        proposal.executed = true;
        // Execute proposal logic
        emit Executed(proposalId);
    }

    function addMember(address newMember) public onlyChairperson {
        members[newMember] = true;
    }

    function removeMember(address member) public onlyChairperson {
        members[member] = false;
    }
}