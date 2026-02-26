// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/LendingPool.sol";
import "../src/MockCollateralToken.sol";
import {MockStableToken} from "../src/MockStableToken.sol";
import {MockPriceOracle} from "../src/MockPriceOracle.sol";

contract DepositTest is Test {
    LendingPool pool;
    MockCollateralToken collateral;
    MockStableToken stable;
    MockPriceOracle oracle;
    

    address user = address(1);

    function setUp()public {
        collateral = new MockCollateralToken();
        stable = new MockStableToken();
        oracle = new MockPriceOracle(1e18);


        pool = new LendingPool(address(collateral), address(stable),address(oracle));

        collateral.mint(user, 1e24);

        vm.prank(user);
        collateral.approve(address(pool), type(uint256).max);
        vm.stopPrank();


    }

    function testDeposite(uint256 amount)public{
        vm.assume(amount> 0 && amount < 1e24);

        vm.startPrank(user);
        pool.deposit(amount);
        vm.stopPrank();

        assertEq(pool.getUserCollateral(user), amount);
    }

}