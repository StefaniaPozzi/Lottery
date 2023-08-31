//SPDX-License-Indentifier:MIT
pragma solidity ^0.8.18;

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

    event Lottery__playerAccepted__event(address indexed player);

    constructor(uint256 _ticketPrice, uint256 _lotteryDuration) {
        i_ticketPrice = _ticketPrice;
        i_lotteryDuration = _lotteryDuration;
        s_lastTimestampSnapshot = block.timestamp;
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
    }

    // Getters
    function getTicketPrice() public returns (uint256) {
        return i_ticketPrice;
    }

    function getLotteryDuration() public returns (uint256) {
        return i_lotteryDuration;
    }
}
