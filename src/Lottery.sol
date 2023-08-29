//SPDX-License-Indentifier:MIT

pragma solidity ^0.8.18;

/**
 * @title A simple lottery contract
 * @author Stefania
 * @notice
 * @dev implements chainlink VRF V2 and chainlink automation
 */
contract Lottery {
    //1. types

    //2. state variables
    uint256 private i_ticketPrice;

    //3. events

    //4.modifiers

    //functions
    constructor(uint256 _ticketPrice) {
        i_ticketPrice = _ticketPrice;
    }

    function buyTicket() public payable {}

    function pickWinner() public {}

    /*Getters*/

    function getTicketPrice() public returns (uint256) {
        return i_ticketPrice;
    }
}
