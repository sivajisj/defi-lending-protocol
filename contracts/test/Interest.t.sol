// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/LendingPool.sol";
import "../src/MockCollateralToken.sol";
import {MockStableToken} from "../src/MockStableToken.sol";
import "../src/MockPriceOracle.sol";

contract InterestTest is Test {

    LendingPool pool;
    MockCollateralToken collateral;
    MockStableToken stable;
    MockPriceOracle oracle;

    address user = address(1);

    function setUp() public {
        collateral = new MockCollateralToken();
        stable = new MockStableToken();
        oracle = new MockPriceOracle(1e18);

        pool = new LendingPool(
            address(collateral),
            address(stable),
            address(oracle)
        );

        collateral.mint(user, 1e24);
        stable.mint(address(pool), 1e24);

        vm.startPrank(user);
        collateral.approve(address(pool), type(uint256).max);
        pool.deposit(1e20);
        pool.borrow(5e19);
        vm.stopPrank();
    }

    function testInterestAccrual() public {
        vm.warp(block.timestamp + 30 days);
        pool.accrueInterest(user);

        assertGt(pool.getUserDebt(user), 5e19);
    }
}