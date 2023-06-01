// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title Roulette
/// @dev This contract represents a simple roulette game where players can place a bet and try to win based on the outcome.
///      The admin is trusted and responsible for ensuring that there are always enough Ether in the contract for users to bet.
contract Roulette {
    /// @dev Event emitted when a user wins the game.
    /// @param user The address of the user who won.
    event Win(address indexed user);

    /// @dev Event emitted when a user loses the game.
    /// @param user The address of the user who lost.
    event Lose(address indexed user);

    address public immutable admin;

    mapping(address => uint256) spinBlockNumber;

    constructor() payable {
        admin = msg.sender;
    }

    /// @dev Function to initiate a spin of the roulette wheel.
    /// @notice Players must send 1 ether to place a bet.
    function spin() external payable {
        require(msg.value == 1 ether, "Incorrect bet amount");
        require(spinBlockNumber[msg.sender] == 0, "Already spun");

        spinBlockNumber[msg.sender] = block.number;
    }

    /// @dev Function to resolve the outcome of the roulette spin.
    function resolve() external {
        uint256 endSpinBlockNumber = spinBlockNumber[msg.sender] + 1;

        require(endSpinBlockNumber > 1, "No spin recorded for the user");
        require(block.number > endSpinBlockNumber, "Spin not completed");

        spinBlockNumber[msg.sender] == 0;

        if (uint256(keccak256(abi.encode(msg.sender, blockhash(endSpinBlockNumber)))) % 2 == 0) {
            emit Win(msg.sender);
            (bool success,) = msg.sender.call{value: 1.95 ether}("");
            require(success, "Transfer failed");
        } else {
            emit Lose(msg.sender);
        }
    }

    /// @dev Allow this contract to eceive Ether.
    /// @notice This function is intended for the admin to fund the contract with Ether.
    receive() external payable {}

    /// @dev Function for the admin to withdraw funds from the contract.
    /// @dev The admin is trusted and responsible for maintaining the contract's balance for gameplay.
    /// @param amount The amount of Ether to withdraw.
    function withdraw(uint256 amount) external {
        require(msg.sender == admin, "Only admin can withdraw");
        (bool success,) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");
    }
}
