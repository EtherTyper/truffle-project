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

contract OutcomeOracle {
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
}

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
        require(
            !oracle.decided() && 0 <= outcome && outcome <= oracle.numOutcomes()
        );
        commodities[outcome].mint(msg.sender, msg.value);
    }

    function payout(address payable recipient) public {
        require(oracle.decided());

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

contract Presidential2020Market is PredictionMarket {
    constructor(address[] memory arbiters)
        PredictionMarket(new OutcomeOracle(arbiters, getCandidates()))
    {}

    function getCandidates() private pure returns (string[] memory) {
        string[] memory candidates = new string[](2);
        candidates[0] = "TRUMP";
        candidates[1] = "BIDEN";
        return candidates;
    }
}
