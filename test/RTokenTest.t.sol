// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {RToken} from "src/RToken.sol";
import {DeployRToken} from "script/DeployRToken.s.sol";

contract RTokenTest is Test {
    error ERC20InsufficientBalance(address sender, uint256 balance, uint256 needed);
    error ERC20InsufficientAllowance(address spender, uint256 allowance, uint256 needed);
    error ERC20InvalidReceiver(address receiver);

    RToken public rToken;
    DeployRToken public deployer;

    address bob = makeAddr("Bob");
    address alice = makeAddr("Alice");
    address charlie = makeAddr("Charlie");

    uint256 constant STARTING_BALANCE = 100 ether;

    function setUp() external {
        deployer = new DeployRToken();
        rToken = deployer.run();
        rToken.transfer(bob, STARTING_BALANCE);
    }

    // === Basic Transfer Tests ===

    function testTransferUpdatesBalances() public {
        uint256 amount = 10 ether;

        vm.prank(bob);
        rToken.transfer(alice, amount);

        assertEq(rToken.balanceOf(alice), amount);
        assertEq(rToken.balanceOf(bob), STARTING_BALANCE - amount);
    }

    function testCannotTransferMoreThanBalance() public {
    uint256 tooMuch = STARTING_BALANCE + 1 ether;

    vm.prank(bob);
    vm.expectRevert(
        abi.encodeWithSelector(
            ERC20InsufficientBalance.selector,
            bob,
            STARTING_BALANCE,
            tooMuch
        )
    );
    rToken.transfer(alice, tooMuch);
    }

    function testTransferToZeroAddressShouldFail() public {
    vm.prank(bob);
    vm.expectRevert(
        abi.encodeWithSelector(
            ERC20InvalidReceiver.selector,
            address(0)
        )
    );
    rToken.transfer(address(0), 1 ether);
    }

    // === Allowance and Approval Tests ===

    function testApproveSetsAllowance() public {
        vm.prank(bob);
        rToken.approve(alice, 500 ether);

        assertEq(rToken.allowance(bob, alice), 500 ether);
    }

    function testTransferFromWithoutApprovalShouldFail() public {
    vm.prank(alice);
    vm.expectRevert(abi.encodeWithSelector(
        ERC20InsufficientAllowance.selector,
        alice,
        0,
        1 ether
    ));
    rToken.transferFrom(bob, alice, 1 ether);
    }

    function testTransferFromWithAllowanceShouldWork() public {
        uint256 allowance = 50 ether;

        vm.prank(bob);
        rToken.approve(alice, allowance);

        vm.prank(alice);
        rToken.transferFrom(bob, charlie, allowance);

        assertEq(rToken.balanceOf(charlie), allowance);
        assertEq(rToken.allowance(bob, alice), 0);
    }

    function testDecreaseAllowanceShouldWork() public {
        vm.prank(bob);
        rToken.approve(alice, 10 ether);

        vm.prank(bob);
        rToken.decreaseAllowance(alice, 5 ether);

        assertEq(rToken.allowance(bob, alice), 5 ether);
    }

    function testDecreaseAllowanceBelowZeroShouldFail() public {
        vm.prank(bob);
        rToken.approve(alice, 3 ether);

        vm.prank(bob);
        vm.expectRevert("ERC20: decreased allowance below zero");
        rToken.decreaseAllowance(alice, 4 ether);
    }

    function testIncreaseAllowanceShouldWork() public {
        vm.prank(bob);
        rToken.increaseAllowance(alice, 2 ether);

        vm.prank(bob);
        rToken.increaseAllowance(alice, 3 ether);

        assertEq(rToken.allowance(bob, alice), 5 ether);
    }

    // === Events ===

    function testTransferEmitsEvent() public {
        vm.expectEmit(true, true, false, true);
        emit Transfer(bob, alice, 1 ether);

        vm.prank(bob);
        rToken.transfer(alice, 1 ether);
    }

    function testApproveEmitsEvent() public {
        vm.expectEmit(true, true, false, true);
        emit Approval(bob, alice, 42 ether);

        vm.prank(bob);
        rToken.approve(alice, 42 ether);
    }

    // === Total Supply Consistency ===

    function testTotalSupplyStaysConstant() public view {
        assertEq(rToken.totalSupply(), rToken.balanceOf(address(this)) + rToken.balanceOf(bob));
    }

    // === Internal ERC20 Events Needed ===

    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);
}
