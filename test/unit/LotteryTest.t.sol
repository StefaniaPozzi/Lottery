//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {LotteryDeploy} from "../../script/LotteryDeploy.s.sol";
import {Lottery} from "../../src/Lottery.sol";
import {Test, console} from "forge-std/Test.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {Vm} from "forge-std/Vm.sol";
import {VRFCoordinatorV2Mock} from "@chainlink/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";

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
    uint256 public constant STARTING_USER_BALANCE = 1 ether;
    event Lottery__PlayerAccepted__event(address indexed player);
    event Lottery__LotteryReset__event();
    event Lottery__WinnerChosen__event(address indexed winner);

    function setUp() external {
        LotteryDeploy lotteryDeploy = new LotteryDeploy();
        (lottery, helperConfig) = lotteryDeploy.run();
        vm.deal(PLAYER, STARTING_USER_BALANCE);
        (
            entranceFee,
            interval,
            vrfCoordinator,
            gasLane,
            subscriptionId,
            ,
            linkToken,

        ) = helperConfig.deploymentNetworkConfig();
    }

    /**
     * Test Utils
     * @dev This util Arranges, Acts, Asserts if:
     *      1. time passed
     *      2. has players
     *      3. open state
     *      4. has balance
     *
     */
    modifier setAllCheckUpkeepParamsToTrue() {
        vm.prank(PLAYER);
        lottery.buyTicket{value: entranceFee}();
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);
        _;
    }

    modifier onlyLocally() {
        if (block.chainid != 31337) {
            return;
        }
        _;
    }

    //tests

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
        lottery.performUpkeep("");
        vm.expectRevert(Lottery.Lottery__ClosedState__error.selector);
        vm.prank(PLAYER);
        lottery.buyTicket{value: entranceFee}();
    }

    function testCheckUpkeepFalseIfHasNoBalance() public {
        vm.warp(block.timestamp + interval + 1);
        (bool upkeepNeeded, ) = lottery.checkUpKeep("");
        assert(!upkeepNeeded);
    }

    function testCheckUpkeepFalseIfEnoughTimeHasntPassed() public {
        vm.prank(PLAYER);
        lottery.buyTicket{value: entranceFee}();
        vm.warp(block.timestamp + interval / 2);
        (bool upkeepNeeded, ) = lottery.checkUpKeep("");
        assert(!upkeepNeeded);
    }

    function testCheckUpkeepAllParamsAreTrue()
        public
        setAllCheckUpkeepParamsToTrue
    {
        (bool upkeepNeeded, ) = lottery.checkUpKeep("");
        assert(upkeepNeeded);
    }

    /**
     * @dev there is no vm.expectNotRevert !
     * -> if the function does not revert,
     * the test is considered passed
     */
    function testPerformUpkeepRunsWhenCheckUpkeepIsTrue()
        public
        setAllCheckUpkeepParamsToTrue
    {
        lottery.performUpkeep("");
    }

    function testPerformupkeepRevertsIfCheckUpkeepIsFalse() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                Lottery.Lottery__UpkeepNotNeeded__error.selector,
                0,
                0,
                0
            )
        );
        lottery.performUpkeep("");
    }

    function testPerformUpkeepAndEmitsRequestId()
        public
        setAllCheckUpkeepParamsToTrue
    {
        vm.recordLogs();
        lottery.performUpkeep("");
        Vm.Log[] memory entries = vm.getRecordedLogs();
        bytes32 requestId = entries[1].topics[1];
        assert(uint256(requestId) > 0);
    }

    /** Fuzzing testma
     * @dev forgeGeneratedRandomNumber
     */
    function testFullfillRandomWordsCalledAfterPerformUpkeep(
        uint32 forgeGeneratedRandomNumber
    ) public setAllCheckUpkeepParamsToTrue onlyLocally {
        vm.expectRevert("nonexistent request");
        //simulation: no real VRF on local chain
        VRFCoordinatorV2Mock(vrfCoordinator).fulfillRandomWords(
            forgeGeneratedRandomNumber,
            address(lottery)
        );
    }

    function testFulfillRandomWordsPicksAWinnerAndSendsBalance()
        public
        setAllCheckUpkeepParamsToTrue
        onlyLocally
    {
        uint256 numberOfPlayers = 3;
        uint256 startIndex = 1;
        uint256 prize = (numberOfPlayers + 1) * entranceFee;

        for (uint256 i = 1; i < numberOfPlayers + startIndex; i++) {
            address addressPlayer = address(uint160(i));
            hoax(addressPlayer, STARTING_USER_BALANCE);
            lottery.buyTicket{value: entranceFee}();
        }

        vm.recordLogs();
        lottery.performUpkeep("");
        Vm.Log[] memory entries = vm.getRecordedLogs();
        bytes32 requestId = entries[1].topics[1];

        VRFCoordinatorV2Mock(vrfCoordinator).fulfillRandomWords(
            uint256(requestId),
            address(lottery)
        );

        assert(lottery.getLastWinner() != address(0));
        assert(
            lottery.getLastWinner().balance ==
                STARTING_USER_BALANCE + prize - entranceFee
        );
    }
}
