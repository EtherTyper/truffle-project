// contracts/oracle/CombinatorialOracle.sol
// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.12;

import "./OutcomeOracle.sol";

// Outcomes will be CSV strings of suboracle outcomes.

abstract contract CombinatorialOracle is OutcomeOracle {
    OutcomeOracle[] public suboracles;
    uint256 public numOutcomes;

    constructor(OutcomeOracle[] memory suboracles_) {
        suboracles = suboracles_;
    }
}
