// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @dev Contract for a simple token that can be sent.
contract SimpleToken {
    mapping(address => int256) public balances;

    /// @dev Creator starts with all the tokens.
    constructor() {
        balances[msg.sender] = 1000e18;
    }

    /// @dev Sends token.
    /// @param recipient The recipient.
    /// @param amount The amount to send.
    function sendToken(address recipient, int256 amount) external {
        balances[msg.sender] -= amount;
        balances[recipient] += amount;
    }
}
