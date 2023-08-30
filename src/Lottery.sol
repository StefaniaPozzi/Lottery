//SPDX-License-Indentifier:MIT

pragma solidity ^0.8.18;

/**
 * @title A simple lottery contract
 * @author Stefania
 * @notice
 * @dev implements chainlink VRF V2 and chainlink automation
 */
contract Lottery {
    //errors
    error Lottery__notEnoughEth__error();
    //types

    //state variables
    uint256 private i_ticketPrice;
    address payable[] private s_players;

    //events

    //modifiers

    //functions

    constructor(uint256 _ticketPrice) {
        i_ticketPrice = _ticketPrice;
    }

    function buyTicket() external payable {
        if (msg.value < i_ticketPrice) {
            revert Lottery__notEnoughEth__error();
        }
        s_players.push(payable(msg.sender));
    }

    function pickWinner() public {}

    /*Getters*/

    function getTicketPrice() public returns (uint256) {
        return i_ticketPrice;
    }
}
