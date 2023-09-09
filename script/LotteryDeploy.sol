//SPDX-License-Identifier:MIT
pragma solidity ^0.8.18;
import {Script} from "forge-std/Script.sol";
import {Lottery} from "../src/Lottery.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {CreateSubscription} from "./Interactions.s.sol";

contract LotteryDeploy is Script {
    function run() external returns (Lottery, HelperConfig) {
        HelperConfig helperConfig = new HelperConfig();
        (   uint256 entranceFee,
            uint256 interval,
            address vrfCoordinator,
            bytes32 gasLane,
            uint64 subscriptionId,
            uint32 callbackGasLimit,
            address linkToken
        ) = helperConfig.deploymentNetworkConfig();
        if (subscriptionId == 0) {
            CreateSubscription subscriptionCreator = new CreateSubscription();
            subscriptionId = subscriptionCreator.createSubscription(
                vrfCoordinator
            );
        }
        vm.startBroadcast();
        Lottery lottery = new Lottery(
            entranceFee,
            interval,
            vrfCoordinator,
            gasLane,
            subscriptionId,
            callbackGasLimit
        );
        vm.stopBroadcast();
        return (lottery, helperConfig);
    }
}
