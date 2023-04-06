// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

contract EventStaking {
    uint256 public eventStartTime;
    uint256 public eventEndTime;

    struct Guest {
        uint256 amount;
        bool present;
    }

    mapping(address => Guest) public guests;

    constructor(uint256 _eventStartTime, uint256 _eventEndTime) {
        eventStartTime = _eventStartTime;
        eventEndTime = _eventEndTime;
    }

    function stakeRSVP() external payable {
        require(block.timestamp <= eventEndTime, "Event has already ended");
        require(msg.value > 0, "You need to stake some ETH");

        guests[msg.sender] = Guest(msg.value, false);
    }

    function attend() external {
        require(block.timestamp >= eventStartTime, "Event has not started yet");
        require(block.timestamp <= eventEndTime, "Event has already ended");
        require(guests[msg.sender].amount > 0, "You have not RSVP'd");
        require(!guests[msg.sender].present, "You have already attended");

        guests[msg.sender].present = true;
        payable(msg.sender).transfer(guests[msg.sender].amount);
    }
}
