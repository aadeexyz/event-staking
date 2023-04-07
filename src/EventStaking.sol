// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import {ReentrancyGuard} from "solmate/utils/ReentrancyGuard.sol";
import {SafeTransferLib} from "solmate/utils/SafeTransferLib.sol";

contract EventStaking is ReentrancyGuard {
    using SafeTransferLib for address;

    uint256 public eventStartTime;
    uint256 public eventEndTime;
    uint256 public totalAmoutRSVPd;
    bool public claimStarted;

    struct Guest {
        uint256 amount;
        bool present;
        bool claimed;
    }

    mapping(address => Guest) public guestsMapping;

    event RSVPd(address indexed _guest, uint256 _amount);
    event Attended(address indexed _guest, uint256 _amount);
    event Claimed(address indexed _guest, uint256 _amount);
    event ClaimStarted();

    constructor(uint256 _eventStartTime, uint256 _eventEndTime) {
        eventStartTime = _eventStartTime;
        eventEndTime = _eventEndTime;
        totalAmoutRSVPd = 0;
        claimStarted = false;
    }

    function stakeRSVP() external payable {
        require(block.timestamp <= eventStartTime, "Event has already started");
        require(msg.value > 0, "You need to stake some ETH");

        guestsMapping[msg.sender] = Guest(
            guestsMapping[msg.sender].amount + msg.value,
            false,
            false
        );
        totalAmoutRSVPd += msg.value;

        emit RSVPd(msg.sender, msg.value);
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

        msg.sender.safeTransferETH(guestsMapping[msg.sender].amount);

        emit Attended(msg.sender, guestsMapping[msg.sender].amount);
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
            address(this).balance;

        guestsMapping[msg.sender].claimed = true;

        msg.sender.safeTransferETH(amount);

        emit Claimed(msg.sender, amount);
    }

    function startClaim() external {
        require(block.timestamp >= eventEndTime, "Event has not ended yet");
        require(!claimStarted, "Claim has already started");

        claimStarted = true;

        emit ClaimStarted();
    }
}
