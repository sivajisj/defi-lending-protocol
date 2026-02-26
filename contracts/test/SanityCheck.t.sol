// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";

contract SanityCheck is Test {
    function testEnvironmentWorks()public pure {
        assertTrue(true);
    }
}