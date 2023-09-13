//SPDX-License-Identifier:MIT
pragma solidity ^0.8.18;
import {Script} from "forge-std/Script.sol";
import {Lottery} from "../src/Lottery.sol";
import {VRFCoordinatorV2Mock} from "@chainlink/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";
import {LinkToken} from "../test/mocks/LinkToken.sol";

contract HelperConfig is Script {
    struct NetworkConfig {
        uint256 entranceFee;
        uint256 interval;
        address vrfCoordinator;
        bytes32 gasLane;
        uint64 subscriptionId;
        uint32 callbackGasLimit;
        address linkToken;
        uint256 deployerKey;
    }

    NetworkConfig public deploymentNetworkConfig;
    uint256 public DEFAULT_ANVIL_PRIVATE_KEY =
        0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;

    constructor() {
        if (block.chainid == 11155111) {
            deploymentNetworkConfig = getSepoliaConfig();
        } else {
            deploymentNetworkConfig = createOrGetAnvilConfig();
        }
    }

    function getSepoliaConfig() public returns (NetworkConfig memory) {
        return
            NetworkConfig({
                entranceFee: 0.01 ether,
                interval: 30,
                vrfCoordinator: 0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625, //https://docs.chain.link/vrf/v2/subscription/supported-networks
                gasLane: 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c,
                subscriptionId: 1703,
                callbackGasLimit: 500000,
                linkToken: 0x779877A7B0D9E8603169DdbD7836e478b4624789,
                deployerKey: vm.envUint("PRIVATE_KEY_METAMASK")
            });
    }

    function createOrGetAnvilConfig() public returns (NetworkConfig memory) {
        if (deploymentNetworkConfig.vrfCoordinator != address(0)) {
            return deploymentNetworkConfig;
        }
        uint96 baseFee = 0.25 ether;
        uint96 gasPriceLink = 1e9; //gwei

        vm.startBroadcast();
        VRFCoordinatorV2Mock vRFmock = new VRFCoordinatorV2Mock(
            baseFee,
            gasPriceLink
        );
        LinkToken linkToken = new LinkToken();
        vm.stopBroadcast();

        return
            NetworkConfig({
                entranceFee: 0.01 ether,
                interval: 30,
                vrfCoordinator: address(vRFmock),
                gasLane: 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c,
                subscriptionId: 0,
                callbackGasLimit: 500000,
                linkToken: address(linkToken),
                deployerKey: DEFAULT_ANVIL_PRIVATE_KEY
            });
    }
}
