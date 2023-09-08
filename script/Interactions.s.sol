//SPDX-License-Identifier:MIT

pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {VRFCoordinatorV2Mock} from "@chainlink/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";

contract CreateSubscription is Script {
    function createSubscriptionForNetwork() public returns (uint64) {
        HelperConfig helperConfig = new HelperConfig();
        (, , address vrfCoordinator, , , ) = helperConfig
            .deploymentNetworkConfig();
    }

    function createSubscription(
        address vrfCoordinator
    ) public returns (uint64) {
        console.log("Created subscription for chain ", block.chainid);
        vm.startBroadcast();
        vm.stopBroadcast();
    }

    function run() external returns (uint64) {
        return createSubscriptionForNetwork();
    }
}
