//SPDX-License-Identifier:MIT
pragma solidity ^0.8.19;
import {Script} from "forge-std/Script.sol";
import {Lottery} from "../src/Lottery.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {CreateSubscription, FundSubscription, AddConsumer} from "./Interactions.s.sol";

contract LotteryDeploy is Script {
    function run() external returns (Lottery, HelperConfig) {
        HelperConfig helperConfig = new HelperConfig();
        AddConsumer addConsumer = new AddConsumer();

        (
            uint256 entranceFee,
            uint256 interval,
            address vrfCoordinator,
            bytes32 gasLane,
            uint64 subscriptionId,
            uint32 callbackGasLimit,
            address linkToken,
            uint256 deployerKey
        ) = helperConfig.deploymentNetworkConfig();
        if (subscriptionId == 0) {
            CreateSubscription subscriptionCreator = new CreateSubscription();
            subscriptionId = subscriptionCreator.createSubscription(
                vrfCoordinator, deployerKey
            );
            FundSubscription fundSubscriptor = new FundSubscription();
            fundSubscriptor.fundSubscription(
                subscriptionId,
                vrfCoordinator,
                linkToken,
                deployerKey
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

        //broadcast alread present
        addConsumer.addConsumer(
            address(lottery),
            subscriptionId,
            vrfCoordinator,
            deployerKey
        );
        return (lottery, helperConfig);
    }
}
