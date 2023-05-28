// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @dev Contract for a simple token that can be exchanged through a bonded curve and sent.
/// @notice We assume that order frontrunning is fine.
contract LinearBondedCurve {
    mapping(address => uint256) public balances;
    uint256 public totalSupply;

    /// @dev Buys token. The price is linear to the total supply.
    function buy() external payable {
        uint256 tokenToReceive = (1e18 * msg.value) / (1e18 + totalSupply);
        balances[msg.sender] += tokenToReceive;
        totalSupply += tokenToReceive;
    }

    /// @dev Sells token. The price of it is linear to the supply.
    /// @param amount The amount of tokens to sell.
    function sell(uint256 amount) external {
        uint256 ethToReceive = ((1e18 + totalSupply) * amount) / 1e18;
        balances[msg.sender] -= amount;
        totalSupply -= amount;
        (bool success,) = msg.sender.call{value: ethToReceive}("");
        require(success, "Transfer failed");
    }

    /// @dev Sends token.
    /// @param recipient The recipient.
    /// @param amount The amount to send.
    function sendToken(address recipient, uint256 amount) external {
        balances[msg.sender] -= amount;
        balances[recipient] += amount;
    }
}
