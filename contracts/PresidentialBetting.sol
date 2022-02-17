// contracts/PresidentialBetting.sol
// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.11;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Commodity is ERC20 {
    address owner;

    constructor(string memory name) ERC20(name, name) {
        owner = msg.sender;
    }

    function mint(address recipient, uint256 amount) public {
        require(msg.sender == owner);
        _mint(recipient, amount);
    }

    function burn(address recipient, uint256 amount) public {
        require(msg.sender == owner);
        _burn(recipient, amount);
    }
}

contract PredictionMarket {
    uint256 numOutcomes;
    address[] public arbiters;
    mapping(address => uint256) public votes;
    Commodity[] commodities;

    bool decided;
    uint256 decision;

    constructor(address[] memory arbiters_, string[] memory outcomes) {
        arbiters = arbiters_;
        numOutcomes = outcomes.length;
        commodities = new Commodity[](numOutcomes);
        for (uint256 i = 0; i < numOutcomes; i++) {
            commodities[i] = new Commodity(outcomes[i]);
        }
    }

    function bet(uint256 outcome) public payable {
        require(!decided && 0 <= outcome && outcome <= numOutcomes);
        commodities[outcome].mint(msg.sender, msg.value);
    }

    function vote(uint256 outcome) public {
        votes[msg.sender] = outcome + 1;
    }

    function recordWinner() public {
        require(!decided);

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

    function payout(address payable recipient) public {
        require(decided);

        uint256 winnerValue = commodities[decision].totalSupply();
        uint256 totalValue = 0;
        for (uint256 i = 0; i < numOutcomes; i++) {
            totalValue += commodities[i].totalSupply();
        }

        uint256 balance = commodities[decision].balanceOf(msg.sender);
        uint256 scaledBalance = (balance * totalValue) / winnerValue;

        commodities[decision].burn(msg.sender, balance);
        recipient.transfer(scaledBalance);
    }
}

contract Presidential2020Market is PredictionMarket {
    constructor(address[] memory arbiters)
        PredictionMarket(arbiters, getCandidates())
    {}

    function getCandidates() private pure returns (string[] memory) {
        string[] memory candidates = new string[](2);
        candidates[0] = "TRUMP";
        candidates[1] = "BIDEN";
        return candidates;
    }
}
