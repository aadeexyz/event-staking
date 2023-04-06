// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import "solmate/auth/Owned.sol";
import "solmate/utils/ReentrancyGuard.sol";

contract EventStaking is Owned, ReentrancyGuard {
    uint256 public eventStartTime;
    uint256 public eventEndTime;
    uint256 public totalAmoutRSVPd;
    uint256 public claimableAmount;
    uint256 public claimedAmount;
    bool public claimStarted;

    struct Guest {
        uint256 amount;
        bool present;
        bool claimed;
    }

    mapping(address => Guest) public guestsMapping;

    constructor(
        uint256 _eventStartTime,
        uint256 _eventEndTime
    ) Owned(msg.sender) {
        eventStartTime = _eventStartTime;
        eventEndTime = _eventEndTime;
        totalAmoutRSVPd = 0;
        claimableAmount = 0;
        claimedAmount = 0;
        claimStarted = false;
    }

    function stakeRSVP() external payable {
        require(block.timestamp <= eventEndTime, "Event has already ended");
        require(msg.value > 0, "You need to stake some ETH");

        guestsMapping[msg.sender] = Guest(
            guestsMapping[msg.sender].amount + msg.value,
            false,
            false
        );
        totalAmoutRSVPd += msg.value;
        claimableAmount += msg.value;
    }

    function attend() external nonReentrant {
        require(block.timestamp >= eventStartTime, "Event has not started yet");
        require(block.timestamp < eventEndTime, "Event has already ended");
        require(guestsMapping[msg.sender].amount > 0, "You have not RSVP'd");
        require(
            !guestsMapping[msg.sender].present,
            "You have already attended"
        );

        guestsMapping[msg.sender].present = true;
        claimedAmount += guestsMapping[msg.sender].amount;
        claimableAmount -= guestsMapping[msg.sender].amount;

        payable(msg.sender).transfer(guestsMapping[msg.sender].amount);
    }

    function claim() external nonReentrant {
        require(claimStarted, "Claim has not started yet");
        require(guestsMapping[msg.sender].amount > 0, "You have not RSVP'd");
        require(
            guestsMapping[msg.sender].present,
            "You did not attend the event"
        );
        require(!guestsMapping[msg.sender].claimed, "You have already claimed");

        uint256 amount = (guestsMapping[msg.sender].amount / totalAmoutRSVPd) *
            claimableAmount;

        guestsMapping[msg.sender].claimed = true;
        claimedAmount += guestsMapping[msg.sender].amount;
        claimableAmount -= guestsMapping[msg.sender].amount;

        payable(msg.sender).transfer(amount);
    }

    function startClaim() external onlyOwner {
        require(block.timestamp >= eventEndTime, "Event has not ended yet");
        require(!claimStarted, "Claim has already started");

        withdrawStuckEther();
        claimStarted = true;
    }

    function withdrawStuckEther() private {
        uint256 amount = address(this).balance - claimableAmount;

        if (amount > 0) {
            payable(msg.sender).transfer(amount);
        }
    }
}
