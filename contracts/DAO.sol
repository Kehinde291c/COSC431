// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

contract SimpleDAO {
    struct Proposal {
        string description;
        uint voteCount;
        bool executed;
    }

    address public chairperson;
    mapping(address => bool) public members;
    Proposal[] public proposals;

    event ProposalCreated(uint proposalId, string description);
    event Voted(uint proposalId, address voter);
    event Executed(uint proposalId);

    modifier onlyMember() {
        require(members[msg.sender], "Not a member");
        _;
    }

    modifier onlyChairperson() {
        require(msg.sender == chairperson, "Not the chairperson");
        _;
    }

    constructor(address[] memory initialMembers) {
        chairperson = msg.sender;
        for (uint i = 0; i < initialMembers.length; i++) {
            members[initialMembers[i]] = true;
        }
    }

    function createProposal(string memory description) public onlyMember {
        proposals.push(Proposal({description: description, voteCount: 0, executed: false}));
        emit ProposalCreated(proposals.length - 1, description);
    }

    function vote(uint proposalId) public onlyMember {
        Proposal storage proposal = proposals[proposalId];
        proposal.voteCount++;
        emit Voted(proposalId, msg.sender);
    }

    function executeProposal(uint proposalId) public onlyChairperson {
        Proposal storage proposal = proposals[proposalId];
        require(proposal.voteCount > getTotalMembers() / 2, "Not enough votes");
        require(!proposal.executed, "Already executed");

        proposal.executed = true;
        // Execute proposal logic
        emit Executed(proposalId);
    }

    function getTotalMembers() public view returns (uint) {
        uint count = 0;
        for (uint i = 0; i < proposals.length; i++) {
            if (members[address(i)]) {
                count++;
            }
        }
        return count;
    }
}