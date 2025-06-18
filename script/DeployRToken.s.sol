// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {RToken} from "src/RToken.sol";

contract DeployRToken is Script {
    uint256 public constant INITIAL_SUPPLY = 1000000 * 10 ** 18; // 1 million tokens with 18 decimals

    function run() external returns (RToken) {
        address testContract = msg.sender;

        vm.startBroadcast();
        RToken rToken = new RToken(INITIAL_SUPPLY);
        rToken.transfer(testContract, INITIAL_SUPPLY); // transfer initial tokens to the test contract, otherwise ERC20InsufficientBalance error
        vm.stopBroadcast();
        return rToken;
    }
}