// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/LendingPool.sol";
import "../src/MockCollateralToken.sol";
import {MockStableToken} from "../src/MockStableToken.sol";

contract WithdrawTest is Test {
    LendingPool pool;
    MockCollateralToken collateral;
    MockStableToken stable;
    MockPriceOracle oracle;

    address user = address(1);

    uint256 constant INITIAL_DEPOSIT = 1e20;

    function setUp() public {
        collateral = new MockCollateralToken();
        stable = new MockStableToken();
        oracle = new MockPriceOracle(1e18);

        pool = new LendingPool(address(collateral), address(stable),address(oracle));

        // Mint collateral to user
        collateral.mint(user, 1e24);

        // User approves pool
        vm.startPrank(user);
        collateral.approve(address(pool), type(uint256).max);

        // Deposit first (required before withdraw)
        pool.deposit(INITIAL_DEPOSIT);
        vm.stopPrank();
    }

    function testWithdraw(uint256 amount) public {
        vm.assume(amount > 0 && amount <= INITIAL_DEPOSIT);

        vm.prank(user);
        pool.withdraw(amount);

        assertEq(
            pool.getUserCollateral(user),
            INITIAL_DEPOSIT - amount
        );
    }
}