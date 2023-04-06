// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

contract EventStaking {
    uint256 public eventStartTime;
    uint256 public eventEndTime;
    uint256 public totalAmoutRSVPd;
    uint256 public claimedAmount;

    struct Guest {
        uint256 amount;
        bool present;
    }

    mapping(address => Guest) public guestsMapping;

    constructor(uint256 _eventStartTime, uint256 _eventEndTime) {
        eventStartTime = _eventStartTime;
        eventEndTime = _eventEndTime;
    }

    function stakeRSVP() external payable {
        require(block.timestamp <= eventEndTime, "Event has already ended");
        require(msg.value > 0, "You need to stake some ETH");

        guestsMapping[msg.sender] = Guest(
            guestsMapping[msg.sender].amount + msg.value,
            false
        );
        totalAmoutRSVPd += msg.value;
    }

    function attend() external {
        require(block.timestamp >= eventStartTime, "Event has not started yet");
        require(block.timestamp < eventEndTime, "Event has already ended");
        require(guestsMapping[msg.sender].amount > 0, "You have not RSVP'd");
        require(
            !guestsMapping[msg.sender].present,
            "You have already attended"
        );

        guestsMapping[msg.sender].present = true;
        payable(msg.sender).transfer(guestsMapping[msg.sender].amount);

        totalAmoutRSVPd -= guestsMapping[msg.sender].amount;
        claimedAmount += guestsMapping[msg.sender].amount;
    }

    function claim() external {
        require(block.timestamp >= eventEndTime, "Event has not ended yet");
        require(guestsMapping[msg.sender].amount > 0, "You have not RSVP'd");
        require(
            guestsMapping[msg.sender].present,
            "You did not attend the event"
        );

        uint256 amount;
    }

    function withdrawStuckEther()
}
