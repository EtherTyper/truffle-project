// contracts/OutcomeOracle.sol
// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.12;

import "./OutcomeOracle.sol";

contract VoteOracle is OutcomeOracle {
    uint256 public numOutcomes;
    address[] public arbiters;
    mapping(address => uint256) public votes;

    string[] public outcomes;

    bool public decided;
    uint256 public decision;

    constructor(address[] memory arbiters_, string[] memory outcomes_) {
        arbiters = arbiters_;
        outcomes = outcomes_;
        numOutcomes = outcomes.length;
    }

    function vote(uint256 outcome) public {
        votes[msg.sender] = outcome + 1;
    }

    function recordWinner() public {
        require(!decided, "No changing existing decision.");

        uint256[] memory voteCounts = new uint256[](numOutcomes);

        for (uint256 i = 0; i < arbiters.length; i++) {
            uint256 arbiterVote = votes[arbiters[i]] - 1;
            if (arbiterVote != 0) {
                voteCounts[arbiterVote]++;
            }
        }

        for (uint256 i = 0; i < numOutcomes; i++) {
            if (3 * voteCounts[i] >= 2 * arbiters.length) {
                // Supermajority vote.
                (decided, decision) = (true, i);
            }
        }

        (decided, decision) = (false, 0);
    }
}
