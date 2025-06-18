// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

// Token is a simple ERC20 token contract with manual minting and burning capabilities.

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Burnable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract RToken is ERC20, ERC20Burnable {
    constructor(uint256 initialSupply) ERC20("RToken", "RTOK") {
        _mint(msg.sender, initialSupply); // Mint initial supply to the contract deployer
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
    address owner = _msgSender();
    _approve(owner, spender, allowance(owner, spender) + addedValue);
    return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
    address owner = _msgSender();
    uint256 currentAllowance = allowance(owner, spender);
    require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
    _approve(owner, spender, currentAllowance - subtractedValue);
    return true;
    }

}