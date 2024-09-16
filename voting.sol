
pragma solidity ^0.8.20;

contract Voting {
    // Struct to represent a proposal
    struct Proposal {
        address target;
        bytes data;
        uint yesCount;
        uint noCount;
        mapping(address => bool) hasVoted;  // To track if an address has voted
        mapping(address => bool) voteChoice; // To track the choice (true for yes, false for no)
        bool executed; // To ensure the proposal is executed only once
    }
    
    Proposal[] public proposals;
    uint public constant MIN_VOTES_FOR_EXECUTION = 10; // Minimum votes to execute proposal

    // Mapping to track allowed members (those who can create proposals and vote)
    mapping(address => bool) public allowedMembers;

    // Event to signal when a new proposal is created
    event ProposalCreated(uint proposalId);
    event VoteCast(uint proposalId, address voter);
    event ProposalExecuted(uint proposalId);

    // Constructor to set allowed members (deployer and array of addresses)
    constructor(address[] memory _members) {
        allowedMembers[msg.sender] = true; // Deployer is allowed

        // Mark all provided addresses as allowed
        for (uint i = 0; i < _members.length; i++) {
            allowedMembers[_members[i]] = true;
        }
    }

    // Modifier to restrict access to only allowed members
    modifier onlyAllowedMembers() {
        require(allowedMembers[msg.sender], "Not authorized to create proposals or vote");
        _;
    }

    // External function to create a new proposal (only allowed members)
    function newProposal(address _target, bytes calldata _data) external onlyAllowedMembers {
        proposals.push();
        Proposal storage newProposal = proposals[proposals.length - 1];
        newProposal.target = _target;
        newProposal.data = _data;
        newProposal.executed = false; // Proposal is not executed yet
        
        emit ProposalCreated(proposals.length - 1);
    }

    // External function to cast or change a vote on a proposal (only allowed members)
    function castVote(uint _proposalId, bool _support) external onlyAllowedMembers {
        require(_proposalId < proposals.length, "Invalid proposal ID");
        Proposal storage proposal = proposals[_proposalId];
        require(!proposal.executed, "Proposal already executed");

        // Check if the voter has voted before
        if (proposal.hasVoted[msg.sender]) {
            // If they have voted, reverse their previous vote
            if (proposal.voteChoice[msg.sender]) {
                proposal.yesCount -= 1;
            } else {
                proposal.noCount -= 1;
            }
        }

        // Record the new vote
        proposal.voteChoice[msg.sender] = _support;
        proposal.hasVoted[msg.sender] = true;

        // Add the new vote to the count
        if (_support) {
            proposal.yesCount += 1;
        } else {
            proposal.noCount += 1;
        }

        emit VoteCast(_proposalId, msg.sender);

        // If 10 or more yes votes, execute the proposal
        if (proposal.yesCount >= MIN_VOTES_FOR_EXECUTION) {
            executeProposal(_proposalId);
        }
    }

    // Internal function to execute a proposal
    function executeProposal(uint _proposalId) internal {
        Proposal storage proposal = proposals[_proposalId];
        require(!proposal.executed, "Proposal already executed");

        // Use call to execute the proposal with the provided data
        (bool success, ) = proposal.target.call(proposal.data);
        require(success, "Proposal execution failed");

        proposal.executed = true; // Mark the proposal as executed
        emit ProposalExecuted(_proposalId);
    }
}
