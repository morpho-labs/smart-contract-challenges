// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @dev Contract for a simple token that can be exchanged through a bonded curve and sent.
/// @notice We assume that order front-running is fine.
contract LinearBondedCurve {
    mapping(address => uint256) public balances;
    uint256 public totalSupply;

    /// @dev Buys tokens. The price is linear to the total supply.
    function buy() external payable {
        uint256 tokensToReceive = (1e18 * msg.value) / (1e18 + totalSupply);
        balances[msg.sender] += tokensToReceive;
        totalSupply += tokensToReceive;
    }

    /// @dev Sells tokens. The price is linear to the supply.
    /// @param amount The amount of tokens to sell.
    function sell(uint256 amount) external {
        uint256 ethToReceive = ((1e18 + totalSupply) * amount) / 1e18;
        balances[msg.sender] -= amount;
        totalSupply -= amount;
        (bool success,) = msg.sender.call{value: ethToReceive}("");
        require(success, "Transfer failed");
    }

    /// @dev Transfers tokens.
    /// @param recipient The recipient.
    /// @param amount The amount to send.
    function transfer(address recipient, uint256 amount) external {
        balances[msg.sender] -= amount;
        balances[recipient] += amount;
    }
}
