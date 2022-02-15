// contracts/PresidentialBetting.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Commodity is ERC20 {
    address owner;

    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
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

enum Candidate {
    None, // MUST BE FIRST (DEFAULT VALUE)
    Trump,
    Biden
}

contract PredictionMarket {
    address[] arbiters;
    mapping (address => Candidate) votes;
    mapping (Candidate => Commodity) commodities;

    constructor(address[] memory arbiters_) {
        commodities[Candidate.Trump] = new Commodity("Trump", "TRUMP");
        commodities[Candidate.Biden] = new Commodity("Biden", "BIDEN");
        arbiters = arbiters_;
    }

    function bet(Candidate candidate) public payable {
        require(candidate != Candidate.None);
        commodities[candidate].mint(msg.sender, msg.value);
    }

    function vote(Candidate winner) public {
        votes[msg.sender] = winner;
    }

    function getWinner() public view returns (Candidate) {
        uint[3] memory voteCounts;

        for (uint i = 0; i < arbiters.length; i++) {
            voteCounts[uint(votes[arbiters[i]])]++;
        }

        uint max;
        for (uint i = 1; i < 3; i++) {
            if (voteCounts[i] >= voteCounts[max]) {
                max = i;
            }
        }

        return Candidate(max);
    }

    function payout(address payable recipient) public {
        Candidate winner = getWinner();
        uint winnerValue = commodities[winner].totalSupply();

        uint totalValue = 0;
        for (uint i = 1; i < 3; i++) {
            totalValue += commodities[Candidate(i)].totalSupply();
        }

        uint balance = commodities[winner].balanceOf(msg.sender);
        uint scaledBalance = (balance * totalValue) / winnerValue;
        
        commodities[winner].burn(msg.sender, balance);
        recipient.transfer(scaledBalance);
    }
}
