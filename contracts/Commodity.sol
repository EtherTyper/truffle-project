// contracts/Commodity.sol
// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.12;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Commodity is ERC20 {
    address private owner;

    constructor(string memory name) ERC20(name, name) {
        owner = msg.sender;
    }

    function mint(address recipient, uint256 amount) public {
        require(msg.sender == owner, "Only owner can mint.");
        _mint(recipient, amount);
    }

    function burn(address recipient, uint256 amount) public {
        require(msg.sender == owner, "Only owner can burn.");
        _burn(recipient, amount);
    }
}
