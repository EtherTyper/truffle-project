// contracts/Presidential2020Market.sol
// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.12;
import "./PredictionMarket.sol";

contract Presidential2020Market is PredictionMarket {
    constructor(address[] memory arbiters)
        PredictionMarket(new OutcomeOracle(arbiters, getCandidates()))
    {}

    function getCandidates() private pure returns (string[] memory) {
        string[] memory candidates = new string[](2);
        candidates[0] = "TRUMP";
        candidates[1] = "NOTRUMP";
        return candidates;
    }
}
