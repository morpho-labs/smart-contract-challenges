// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @dev Enables users to buy objects at discounted prices.
contract DiscountedBuy {
    uint256 public constant BASE_PRICE = 1 ether;
    mapping(address => uint256) public objectsBought;

    /// @dev Allows a user to buy an object by paying the appropriate price.
    /// @notice The price is calculated as `BASE_PRICE / (1 + objectsBought[msg.sender])`.
    function buy() external payable {
        require(msg.value * (1 + objectsBought[msg.sender]) == BASE_PRICE, "Incorrect payment amount");
        objectsBought[msg.sender]++;
    }

    /// @dev Calculates and returns the price of the next object to be purchased.
    /// @return The amount to be paid in wei.
    function price() external view returns (uint256) {
        return BASE_PRICE / (1 + objectsBought[msg.sender]);
    }
}
