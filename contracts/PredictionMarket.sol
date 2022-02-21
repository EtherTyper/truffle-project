// contracts/PresidentialBetting.sol
// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.12;
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

    function bet(address[] memory recipients) public payable {
        require(!oracle.decided(), "No betting after decision.");
        require(
            recipients.length == oracle.numOutcomes(),
            "One recipient per outcome."
        );
        for (uint256 i = 0; i < oracle.numOutcomes(); i++) {
            commodities[i].mint(recipients[i], msg.value);
        }
    }

    function payout(address payable recipient) public {
        require(oracle.decided(), "No payouts before decision.");

        Commodity winner = commodities[oracle.decision()];
        uint256 balance = winner.balanceOf(msg.sender);

        winner.burn(msg.sender, balance);
        recipient.transfer(balance);
    }
}
