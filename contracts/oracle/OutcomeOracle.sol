// contracts/oracle/OutcomeOracle.sol
// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.12;

interface OutcomeOracle {
    function numOutcomes() external returns (uint256);

    function arbiters(uint256) external returns (address);

    function votes(address) external returns (uint256);

    function outcomes(uint256) external returns (string memory);

    function decided() external returns (bool);

    function decision() external returns (uint256);

    function vote(uint256 outcome) external;

    function recordWinner() external;
}
