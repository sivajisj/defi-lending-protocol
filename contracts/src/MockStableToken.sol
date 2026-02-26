// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

error NotAuthorized();
error ZeroAmount();

contract MockStableToken is ERC20, Ownable {

    event Minted(address indexed to, uint256 amount);

    constructor()  ERC20("Mock Collateral Token", "MCT") 
        Ownable(msg.sender) {}

    function mint(address to, uint256 amount) external onlyOwner {
        if (amount == 0) revert ZeroAmount();
        _mint(to, amount);
        emit Minted(to, amount);
    }
}