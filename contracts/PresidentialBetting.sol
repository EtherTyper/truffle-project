// contracts/PresidentialBetting.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Commodity is ERC20 {
    address owner;

    constructor(string memory name) ERC20(name, name) {
        owner = msg.sender;
    }

    function mint(address recipient, uint amount) public {
        require(msg.sender == owner);
        _mint(recipient, amount);
    }

    function burn(address recipient, uint amount) public {
        require(msg.sender == owner);
        _burn(recipient, amount);
    }
}

contract PredictionMarket {
    uint numOutcomes;
    address[] public arbiters;
    mapping (address => uint) public votes;
    Commodity[] commodities;

    constructor(address[] memory arbiters_, string[] memory outcomes) {
        arbiters = arbiters_;
        numOutcomes = outcomes.length;
        commodities = new Commodity[](numOutcomes);
        for (uint i = 0; i < numOutcomes; i++) {
            commodities[i] = new Commodity(outcomes[i]);
        }
    }

    function bet(uint outcome) public payable {
        require(0 <= outcome && outcome <= numOutcomes);
        commodities[outcome].mint(msg.sender, msg.value);
    }

    function vote(uint outcome) public {
        votes[msg.sender] = outcome;
    }

    function getWinner() public view returns (bool decided, uint decision) {
        uint[] memory voteCounts = new uint[](numOutcomes);

        for (uint i = 0; i < arbiters.length; i++) {
            voteCounts[uint(votes[arbiters[i]])]++;
        }

        for (uint i = 0; i < numOutcomes; i++) {
            if (3 * voteCounts[i] >= 2 * arbiters.length) {
                // Supermajority vote.
                return (true, i);
            }
        }

        return (false, 0);
    }

    function payout(address payable recipient) public {
        (bool decided, uint trueOutcome) = getWinner();
        require(decided);

        uint winnerValue = commodities[trueOutcome].totalSupply();
        uint totalValue = 0;
        for (uint i = 0; i < numOutcomes; i++) {
            totalValue += commodities[i].totalSupply();
        }

        uint balance = commodities[trueOutcome].balanceOf(msg.sender);
        uint scaledBalance = (balance * totalValue) / winnerValue;

        commodities[trueOutcome].burn(msg.sender, balance);
        recipient.transfer(scaledBalance);
    }
}

contract Presidential2020Market is PredictionMarket {
    constructor(address[] memory arbiters) PredictionMarket(arbiters, getCandidates()) {}
    function getCandidates() private pure returns (string[] memory) {
        string[] memory candidates = new string[](2);
        candidates[0] = "TRUMP";
        candidates[1] = "BIDEN";
        return candidates;
    }
}
