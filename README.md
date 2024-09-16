Voting Contract

Proposal Creation:
Allows authorized members to create new proposals.
Each proposal targets an address and sends calldata to execute specific functions on the target contract.

Member-based System:
Constructor initializes with an array of member addresses.
Only members can create proposals or vote on them.

Voting Mechanism:
Each proposal tracks yes/no votes using yesCount and noCount.
Members can cast or change their vote for a specific proposal.

Execution on Voting Threshold:
Once 10 yes votes are reached, the proposal is executed.
Proposals execute by sending the provided calldata to the target address using the call function.

Event-Driven:
Emits events for proposal creation (ProposalCreated) and vote casting (VoteCast).

Security Checks:
Ensures only authorized members can interact with the contract (create proposals or vote).
Prevents non-members from unauthorized actions.

Flexible Calldata Execution:
Supports executing any calldata, allowing flexible interaction with external contracts or systems.

This contract provides a decentralized governance mechanism, ideal for managing protocol upgrades or other critical decisions through community votes.
