// contracts/PresidentialBetting.sol
// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.11;
import "./Commodity.sol";
import "./OutcomeOracle.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract PredictionMarket {
    Commodity[] public commodities;
    OutcomeOracle public oracle;

    constructor(OutcomeOracle oracle_) {
        oracle = oracle_;
        commodities = new Commodity[](oracle.numOutcomes());
        for (uint256 i = 0; i < oracle.numOutcomes(); i++) {
            commodities[i] = new Commodity(oracle.outcomes(i));
        }
    }

    function bet(uint256 outcome) public payable {
        require(!oracle.decided(), "No betting after decision.");
        require(
            0 <= outcome && outcome <= oracle.numOutcomes(),
            "Invalid outcome specified."
        );
        commodities[outcome].mint(msg.sender, msg.value);
    }

    function payout(address payable recipient) public {
        require(oracle.decided(), "No payouts before decision.");

        uint256 winnerValue = commodities[oracle.decision()].totalSupply();
        uint256 totalValue = 0;
        for (uint256 i = 0; i < oracle.numOutcomes(); i++) {
            totalValue += commodities[i].totalSupply();
        }

        uint256 balance = commodities[oracle.decision()].balanceOf(msg.sender);
        uint256 scaledBalance = (balance * totalValue) / winnerValue;

        commodities[oracle.decision()].burn(msg.sender, balance);
        recipient.transfer(scaledBalance);
    }
}
