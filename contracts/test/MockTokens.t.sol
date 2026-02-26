// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol" ;
import { MockCollateralToken} from "../src/MockCollateralToken.sol";
import {MockStableToken} from "../src/MockStableToken.sol";

contract MockTokensTest is Test{
    MockCollateralToken collateral;
    MockStableToken stable;

    address user = address(1);

    function setUp() public{
        collateral = new MockCollateralToken();
        stable = new MockStableToken();
    }

    function testOwnerCanMintCollateral(uint256 amount) public{
        vm.assume(amount > 0 && amount < 1e24);

        collateral.mint(user,amount);
        assertEq(collateral.balanceOf(user), amount);
    }

    function ownerCanMintStable(uint256 amount) public{
        vm.assume(amount > 0 && amount < 1e24);

        stable.mint(user, amount);
        assertEq(stable.balanceOf(user), amount);
    }

    function testNonOwnerCannotMint() public{
        vm.prank(user);
        vm.expectRevert();
        collateral.mint(user, 100);
    }
}