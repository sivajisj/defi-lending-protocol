// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "forge-std/StdInvariant.sol";

import "../../src/LendingPool.sol";
import "../../src/MockCollateralToken.sol";
import {MockStableToken} from "../../src/MockStableToken.sol";
import "../../src/MockPriceOracle.sol";

contract LendingPoolInvariant is StdInvariant, Test {
    LendingPool pool;
    MockCollateralToken collateral;
    MockStableToken stable;
    MockPriceOracle oracle;

    function setUp()public {
        collateral = new MockCollateralToken();
        stable = new MockStableToken();
        oracle = new MockPriceOracle(1e18);
        pool = new LendingPool(
            address(collateral),
            address(stable),
            address(oracle)
        );
        collateral.mint(address(this), 1e24);
        stable.mint(address(pool), 1e24);
        collateral.approve(address(pool), type(uint256).max);

        targetContract(address(pool));
    }
     /*
        INVARIANT 1:
        Protocol must remain solvent.
    */
   function invariant_protocolSolvent() public view{
        uint256 deposits = pool.totalDeposits();
        uint256 borrows = pool.totalBorrows();

        assertGe(deposits, borrows);
    }

    /*
        INVARIANT 2:
        Token balance must match accounting.
    */
    function invariant_balanceIntegrity() public view{
        uint256 actualBalance =
            collateral.balanceOf(address(pool));

        assertEq(actualBalance, pool.totalDeposits());
    }
}