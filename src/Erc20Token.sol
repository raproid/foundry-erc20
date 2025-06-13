// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

// Token is a simple ERC20 token contract with manual minting and burning capabilities.

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Erc20Token is ERC20 {
    constructor(uint256 initialSupply) ERC20("Aw, some token", "AWSOME") {
        _mint(msg.sender, initialSupply * 10 ** decimals()); // Mint initial supply to the contract deployer
    }
}