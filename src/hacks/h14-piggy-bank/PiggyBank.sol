// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @dev This is a piggy bank.
///      The owner can deposit 1 ETH whenever they want.
///      They can only withdraw when the deposited amount reaches 10 ETH.
contract PiggyBank {
    address public immutable owner;

    /// @dev Sets the deployer as the owner.
    constructor() {
        owner = msg.sender;
    }

    /// @dev Deposits 1 ETH in the smart contract.
    function deposit() external payable {
        require(msg.sender == owner, "Only the owner can deposit");
        require(msg.value == 1 ether, "Deposit amount must be 1 ETH");
        require(address(this).balance <= 10 ether, "Deposit limit exceeded");
    }

    /// @dev Withdraws the entire smart contract balance when the deposited amount reaches 10 ETH.
    function withdraw() external {
        require(msg.sender == owner, "Only the owner can withdraw");
        require(address(this).balance == 10 ether, "Cannot withdraw before reaching 10 ETH");

        (bool success,) = msg.sender.call{value: address(this).balance}("");
        require(success, "Transfer failed");
    }
}
