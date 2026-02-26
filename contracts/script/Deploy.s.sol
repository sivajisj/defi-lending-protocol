// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";

import "../src/MockCollateralToken.sol";
import {MockStableToken} from "../src/MockStableToken.sol";
import "../src/MockPriceOracle.sol";
import "../src/LendingPool.sol";

contract DeployMiniAave is Script {
function run() external {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

    vm.startBroadcast(deployerPrivateKey);

    MockCollateralToken collateral =
        new MockCollateralToken();

    MockStableToken stable =
        new MockStableToken();

    MockPriceOracle oracle =
        new MockPriceOracle(1e18);

    LendingPool pool = new LendingPool(
        address(collateral),
        address(stable),
        address(oracle)
    );

    // Mint collateral to deployer
    collateral.mint(vm.addr(deployerPrivateKey), 1e24);

    // Provide liquidity
    stable.mint(address(pool), 1e24);

    vm.stopBroadcast();
}
}