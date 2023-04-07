// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import {Test} from "forge-std/Test.sol";
import {EventStaking} from "src/EventStaking.sol";

contract EventStakingTest is Test {
    EventStaking eventStaking;

    uint256 eventStartTime = 69;
    uint256 eventEndTime = 420;

    function setUp() public {
        eventStaking = new EventStaking(eventStartTime, eventEndTime);
    }

    function test_StakeRSVP() public {
        uint256 amount = 100;
        eventStaking.stakeRSVP{value: amount}();
        assertEq(eventStaking.totalAmoutRSVPd(), amount);
        assertEq(address(eventStaking).balance, amount);
    }

    function test_Attend() public {
        uint256 amount = 100;
        eventStaking.stakeRSVP{value: amount}();
        vm.warp(eventStartTime);
        eventStaking.attend();
        assertEq(eventStaking.totalAmoutRSVPd(), amount);
        assertEq(address(eventStaking).balance, 0);
    }

    function test_CannotAttendIfEventNotStarted() public {
        uint256 amount = 100;
        eventStaking.stakeRSVP{value: amount}();
        vm.warp(eventStartTime - 1);
        vm.expectRevert("Event has not started yet");
        eventStaking.attend();
    }

    function test_CannotAttendTwice() public {
        uint256 amount = 100;
        eventStaking.stakeRSVP{value: amount}();
        vm.warp(eventStartTime);
        eventStaking.attend();
        vm.expectRevert("You have already attended");
        eventStaking.attend();
    }

    function test_Claim() public {
        uint256 amount = 100;
        eventStaking.stakeRSVP{value: amount}();
        vm.warp(eventStartTime);
        eventStaking.attend();
        vm.warp(eventEndTime);
        eventStaking.startClaim();
        eventStaking.claim();
        assertEq(eventStaking.totalAmoutRSVPd(), amount);
        assertEq(address(eventStaking).balance, 0);
    }

    function test_CannotStartClaimIfEventNotEnded() public {
        uint256 amount = 100;
        eventStaking.stakeRSVP{value: amount}();
        vm.warp(eventStartTime);
        eventStaking.attend();
        vm.warp(eventEndTime - 1);
        vm.expectRevert("Event has not ended yet");
        eventStaking.startClaim();
    }

    function test_CannotClaimIfNotAttended() public {
        uint256 amount = 100;
        eventStaking.stakeRSVP{value: amount}();
        vm.warp(eventEndTime);
        eventStaking.startClaim();
        vm.expectRevert("You did not attend the event");
        eventStaking.claim();
    }

    function test_CannotClaimIfNotStarted() public {
        uint256 amount = 100;
        eventStaking.stakeRSVP{value: amount}();
        vm.warp(eventStartTime);
        eventStaking.attend();
        vm.warp(eventEndTime - 1);
        vm.expectRevert("Claim has not started yet");
        eventStaking.claim();
    }

    function test_CannotClaimTwice() public {
        uint256 amount = 100;
        eventStaking.stakeRSVP{value: amount}();
        vm.warp(eventStartTime);
        eventStaking.attend();
        vm.warp(eventEndTime);
        eventStaking.startClaim();
        eventStaking.claim();
        vm.expectRevert("You have already claimed");
        eventStaking.claim();
    }

    function test_CannotClaimIfNotRSVPd() public {
        vm.warp(eventEndTime);
        eventStaking.startClaim();
        vm.expectRevert("You have not RSVP'd");
        eventStaking.claim();
    }

    receive() external payable {}
}
