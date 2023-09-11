//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {LotteryDeploy} from "../../script/LotteryDeploy.sol";
import {Lottery} from "../../src/Lottery.sol";
import {Test, console} from "forge-std/Test.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {Vm} from "forge-std/Vm.sol";

contract LotteryTest is Test {
    Lottery lottery;
    HelperConfig helperConfig;
    uint256 entranceFee;
    uint256 interval;
    address vrfCoordinator;
    bytes32 gasLane;
    uint64 subscriptionId;
    uint32 callbackGasLimit;
    address linkToken;
    uint256 deployerKey;

    address public PLAYER = makeAddr("player");
    uint256 public constant STARTING_USER_BALANCE = 10 ether;
    event Lottery__PlayerAccepted__event(address indexed player);
    event Lottery__LotteryReset__event();
    event Lottery__WinnerChosen__event(address indexed winner);

    function setUp() external {
        LotteryDeploy lotteryDeploy = new LotteryDeploy();
        (lottery, helperConfig) = lotteryDeploy.run();
        (
            entranceFee,
            interval,
            vrfCoordinator,
            gasLane,
            subscriptionId,
            callbackGasLimit,
            linkToken,
            deployerKey
        ) = helperConfig.deploymentNetworkConfig();
        vm.deal(PLAYER, STARTING_USER_BALANCE);
    }

    function testInitializesInOpenState() public view {
        assert(lottery.getLotteryState() == Lottery.LotteryState.OPEN);
    }

    function testLotteryRevertWhenValueBelowTicketPrice() public {
        vm.prank(PLAYER);
        vm.expectRevert(
            Lottery.Lottery__EthValueBelowTicketPrice__error.selector
        );
        lottery.buyTicket();
    }

    function testUserIsRegisteredWhenEnteredTicket() public {
        vm.prank(PLAYER);
        lottery.buyTicket{value: entranceFee}();
        address currentPlayer = lottery.getPlayer(0);
        assert(currentPlayer == PLAYER);
    }

    function testEmitsEventWhenBuyingTicket() public {
        vm.prank(PLAYER);
        vm.expectEmit(true, false, false, false, address(lottery));
        emit Lottery__PlayerAccepted__event(PLAYER);
        lottery.buyTicket{value: entranceFee}();
    }

    function testRevertsWhenBuyTicketDuringCalculatingState() public {
        vm.prank(PLAYER);
        lottery.buyTicket{value: entranceFee}();
        vm.warp(block.timestamp + interval + 1);
        lottery.performUpkeep();
        vm.expectRevert(Lottery.Lottery__ClosedState__error.selector);
        vm.prank(PLAYER);
        lottery.buyTicket{value: entranceFee}(); //Invalid consumer
    }
}
