//SPDX-License-Identifier:MIT

pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {VRFCoordinatorV2Mock} from "@chainlink/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";
import {LinkToken} from "../test/mocks/LinkToken.sol";

contract CreateSubscription is Script {
    function createSubscriptionForNetwork() public returns (uint64) {
        HelperConfig helperConfig = new HelperConfig();
        (, , address vrfCoordinator, , , , ) = helperConfig
            .deploymentNetworkConfig();
    }

    function createSubscription(
        address vrfCoordinator
    ) public returns (uint64) {
        console.log("Created subscription for chain ", block.chainid);
        vm.startBroadcast();
        uint64 subId = VRFCoordinatorV2Mock(vrfCoordinator)
            .createSubscription();
        console.log(subId);
        vm.stopBroadcast();
    }

    function run() external returns (uint64) {
        return createSubscriptionForNetwork();
    }
}

contract FundSubscription is Script {
    uint96 public constant FUND_AMOUNT = 0.01 ether;

    function fundSubscription(
        address vrfCoordinator,
        uint64 subscriptionId,
        address linkToken
    ) public {
        console.log("Fundiong subscription ", subscriptionId);
        console.log("Using vrf coordinator ", vrfCoordinator);
        console.log("On chainid ", block.chainid);
        if (block.chainid == 31337) {
            vm.startBroadcast();
            VRFCoordinatorV2Mock(vrfCoordinator).fundSubscription(
                subscriptionId,
                FUND_AMOUNT
            );
            vm.stopBroadcast();
        } else {
            vm.startBroadcast();
            LinkToken(linkToken).transferAndCall(
                vrfCoordinator,
                FUND_AMOUNT,
                abi.encode(subscriptionId)
            );
            vm.stopBroadcast();
        }
    }

    function fundSubscriptionForNetwork() public {
        HelperConfig helperConfig = new HelperConfig();
        (
            ,
            ,
            address vrfCoordinator,
            ,
            uint64 subscriptionId,
            ,
            address linkToken
        ) = helperConfig.deploymentNetworkConfig();
        fundSubscription(vrfCoordinator, subscriptionId, linkToken);
    }

    function run() external {
        fundSubscriptionForNetwork();
    }
}
