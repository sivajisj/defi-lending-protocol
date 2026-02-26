// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/*
    Simplified price oracle mock.

    - Admin-controlled price updates.
    - Returns collateral price in USD (1e18 precision).
*/
import "@openzeppelin/contracts/access/Ownable.sol";

error ZeroPrice();
contract MockPriceOracle is Ownable{
    uint256 private price;

    event PriceUpdated(uint256 newPrice);

    constructor(uint256 intialPrice) Ownable(msg.sender) onlyOwner{
        if (intialPrice == 0 ) revert ZeroPrice();
        price = intialPrice;
    }

    function setPrice(uint256 newPrice) external onlyOwner {
        if (newPrice == 0) revert ZeroPrice();
        price = newPrice;
        emit PriceUpdated(newPrice);
    }

    function getPrice() external view returns (uint256) {
        return price;
    }



}