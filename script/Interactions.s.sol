//SPDX-License-Identifier:MIT

pragma solidity ^0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {VRFCoordinatorV2Mock} from "@chainlink/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";
import {LinkToken} from "../test/mocks/LinkToken.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";

contract CreateSubscription is Script {
    function createSubscriptionForNetwork() public returns (uint64) {
        HelperConfig helperConfig = new HelperConfig();
        (, , address vrfCoordinator, , , , , uint256 deployerKey) = helperConfig
            .deploymentNetworkConfig();
        createSubscription(vrfCoordinator, deployerKey);
    }

    function createSubscription(
        address vrfCoordinator,
        uint256 deployerKey
    ) public returns (uint64 subId) {
        console.log("Created subscription for chain ", block.chainid);
        vm.startBroadcast(deployerKey);
        subId = VRFCoordinatorV2Mock(vrfCoordinator).createSubscription();
        vm.stopBroadcast(); //HERE
    }

    function run() external returns (uint64) {
        return createSubscriptionForNetwork();
    }
}

contract FundSubscription is Script {
    uint96 public constant FUND_AMOUNT = 10 ether;

    function fundSubscription(
        uint64 subscriptionId,
        address vrfCoordinator,
        address linkToken,
        uint256 deployerKey
    ) public {
        console.log("Fundiong subscription ", subscriptionId);
        console.log("Using vrf coordinator ", vrfCoordinator);
        console.log("On chainid ", block.chainid);

        if (block.chainid == 31337) {
            vm.startBroadcast(deployerKey);
            VRFCoordinatorV2Mock(vrfCoordinator).fundSubscription(
                subscriptionId,
                FUND_AMOUNT
            );
            vm.stopBroadcast();
        } else {
            vm.startBroadcast(deployerKey);
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
            address linkToken,
            uint256 deployerKey
        ) = helperConfig.deploymentNetworkConfig();
        fundSubscription(
            subscriptionId,
            vrfCoordinator,
            linkToken,
            deployerKey
        );
    }

    function run() external {
        fundSubscriptionForNetwork();
    }
}

contract AddConsumer is Script {
    function addConsumer(
        address lottery,
        uint64 subscriptionId,
        address vrfCoordinator,
        uint256 deployerKey
    ) public {
        console.log("Adding consumer contract: ", lottery);
        console.log("Using vrfCoordinator: ", vrfCoordinator);
        console.log("On ChainID: ", block.chainid);
        console.log(deployerKey);
        vm.startBroadcast(deployerKey);
        VRFCoordinatorV2Mock(vrfCoordinator).addConsumer(
            subscriptionId,
            lottery
        );
        vm.stopBroadcast();
    }

    function addConsumerForNetwork(address lottery) public {
        HelperConfig helperConfig = new HelperConfig();
        (
            ,
            ,
            address vrfCoordinator,
            ,
            uint64 subscriptionId,
            ,
            ,
            uint256 deployerKey
        ) = helperConfig.deploymentNetworkConfig();
        addConsumer(lottery, subscriptionId, vrfCoordinator, deployerKey);
    }

    function run() external {
        address lottery = DevOpsTools.get_most_recent_deployment(
            "Lottery",
            block.chainid
        );
        addConsumerForNetwork(lottery);
    }
}
