//SPDX-License-Indentifier:MIT
pragma solidity ^0.8.18;

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";

/**
 * @title A simple lottery contract
 * @author Stefania
 * @notice
 * @dev implements chainlink VRF V2 and chainlink automation
 */
contract Lottery {
    /** Layout of contracts: ErTS, EvMF
     * ErTS
     * errors, types, state variables
     * EvMF
     * events, modifiers, fucntions
     */
    error Lottery__notEnoughEth__error();
    // @dev duration of the lottery
    uint256 private immutable i_lotteryDuration;
    uint256 private immutable i_ticketPrice;
    address payable[] private s_players;
    // @dev always a smaller number than block.timestamp
    uint256 private s_lastTimestampSnapshot;

    //VRF
    //1. chain dependent vars
    VRFCoordinatorV2Interface private immutable i_VRFCoordinator;
    bytes32 private immutable i_gasLane;
    uint64 private immutable i_subscriptionId;
    uint32 private immutable i_callbackGasLimit;

    //2. constants
    uint256 private REQUEST_CONFIRMATIONS = 2;
    uint32 private NUM_WORDS = 1;

    event Lottery__playerAccepted__event(address indexed player);

    constructor(
        uint256 _ticketPrice,
        uint256 _lotteryDuration,
        VRFCoordinatorV2Interface _VRFCoordinator,
        bytes32 _gasLane,
        uint64 _subscriptionId,
        uint32 _callbackGasLimit
    ) {
        i_ticketPrice = _ticketPrice;
        i_lotteryDuration = _lotteryDuration;
        s_lastTimestampSnapshot = block.timestamp;
        i_VRFCoordinator = _VRFCoordinator;
        i_gasLane = _gasLane;
        i_subscriptionId = _subscriptionId;
        i_callbackGasLimit = _callbackGasLimit;
    }

    function buyTicket() external payable {
        if (msg.value < i_ticketPrice) {
            revert Lottery__notEnoughEth__error();
        }
        s_players.push(payable(msg.sender));
        emit Lottery__playerAccepted__event(msg.sender);
    }

    function pickWinner() public {
        if ((block.timestamp - s_lastTimestampSnapshot) < i_lotteryDuration) {
            revert();
        }
        uint256 requestId = i_VRFCoordinator.requestRandomWords(
            i_gasLane,
            i_subscriptionId,
            REQUEST_CONFIRMATIONS,
            i_callbackGasLimit,
            NUM_WORDS
        );
    }

    // Getters
    function getTicketPrice() public returns (uint256) {
        return i_ticketPrice;
    }

    function getLotteryDuration() public returns (uint256) {
        return i_lotteryDuration;
    }
}
