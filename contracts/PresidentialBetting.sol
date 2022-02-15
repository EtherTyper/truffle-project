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

enum Candidate {
    None, // MUST BE FIRST (DEFAULT VALUE)
    Trump,
    Biden
}

contract PredictionMarket {
    address[] public arbiters;
    mapping (address => Candidate) public votes;
    mapping (Candidate => Commodity) commodities;

    constructor(address[] memory arbiters_) {
        commodities[Candidate.Trump] = new Commodity("TRUMP");
        commodities[Candidate.Biden] = new Commodity("BIDEN");
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

        for (uint i = 0; i < 3; i++) {
            if (3 * voteCounts[i] >= 2 * arbiters.length) {
                // Supermajority vote.
                return Candidate(i);
            }
        }

        return Candidate.None;
    }

    function payout(address payable recipient) public {
        Candidate winner = getWinner();
        require(winner != Candidate.None);

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
