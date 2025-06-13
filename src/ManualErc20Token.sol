// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

// ManualToken is a simple ERC20 token contract with manual minting and burning capabilities.

contract ManualToken {
    // _address_ assigned _amount_ of tokens
    mapping (address => uint256) private s_balances;

    function name() public pure returns (string memory) {
        return "ManualToken";
    }
    function totalSupply() public pure returns (uint256) {
        return 1000000 * 10 ** 18; // 1 million tokens with 18 decimals
    }
    function decimals() public pure returns (uint8) {
        return 18; // Standard ERC20 token decimal
    }
    function balanceOf(address _owner) public view returns (uint256) {
        return s_balances[_owner]; // Each account starts with 1000 tokens
    }

    function transfer(address _to, uint256 _amount) public returns (bool) {
        uint256 previousBalance = s_balances[msg.sender] + s_balances[_to];
        s_balances[msg.sender] -= _amount;
        s_balances[_to] += _amount;
        require(s_balances[msg.sender] + s_balances[_to] == previousBalance);
        return true;
    }

}