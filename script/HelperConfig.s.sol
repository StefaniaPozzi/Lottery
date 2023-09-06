//SPDX-License-Identifier:MIT
pragma solidity ^0.8.18;
import {Script} from "forge-std/Script.sol";
import {Lottery} from "../src/Lottery.sol";

contract HelperConfig is Script{
    struct NetworkConfig{
        uint256 entranceFee;
        uint256 intercal;
        address vrfCoordinator;
        bytes32 gasLane;
        uint64 subscriptionId;
        uint32 callbackGasLimit;
    }
}