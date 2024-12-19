// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Test} from "forge-std/Test.sol";
import {NotBasedToken} from "../src/NotBasedToken.sol";
import {NotBasedRewarder} from "../src/NotBasedToken.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract NotBasedRewarderTest is Test {
    NotBasedToken rewardToken;
    NotBasedToken depositToken;
    NotBasedRewarder rewarder;

    address user = address(1);

    function setUp() public {
        // Deploy tokens
        rewardToken = new NotBasedToken(address(this));
        depositToken = new NotBasedToken(address(this));

        // Deploy rewarder contract
        rewarder = new NotBasedRewarder(IERC20(address(rewardToken)), IERC20(address(depositToken)));

        // Mint tokens to user
        rewardToken.transfer(user, 1000e18);
        depositToken.transfer(user, 1000e18);

        // Approve rewarder contract
        vm.prank(user);
        rewardToken.approve(address(rewarder), 1000e18);
        vm.prank(user);
        depositToken.approve(address(rewarder), 1000e18);
    }

    function testWithdrawFailsDueToInsufficientBalance() public {
        vm.startPrank(user);

        // User deposits 100 tokens
        rewarder.deposit(100e18);

        // Attempt to withdraw more than deposited
        vm.expectRevert("insufficient balance");
        rewarder.withdraw(200e18);

        vm.stopPrank();
    }

    function testWithdrawFailsDueToPausedRewardToken() public {
        vm.startPrank(user);
        // User deposits 100 tokens
        rewarder.deposit(100e18);

        // Fast-forward time to meet the bonus condition (24+ hours)
        vm.warp(block.timestamp + 25 hours);
        vm.stopPrank();

        vm.startPrank(address(this));
        rewardToken.pause();
        vm.stopPrank();

        // Try withdrawing tokens
        vm.startPrank(user);
        vm.expectRevert(); // Expect revert due to paused token
        rewarder.withdraw(100e18);

        vm.stopPrank();
    }
}
