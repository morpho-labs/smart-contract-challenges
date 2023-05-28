// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @dev A Token contract that keeps a record of the user's past balances.
contract SnapshotToken {
    mapping(address => uint256) public balances;
    mapping(address => mapping(uint256 => uint256)) public balancesAt;

    event BalanceUpdated(address indexed user, uint256 oldBalance, uint256 newBalance);

    /// @dev Buys tokens at the price of 1 ETH per token.
    function buyToken() external payable {
        uint256 balance = balances[msg.sender];
        uint256 newBalance = balance + msg.value / 1 ether;
        balances[msg.sender] = newBalance;

        _updateCheckpoint(msg.sender, balance, newBalance);
    }

    /// @dev Transfers tokens.
    /// @param to The recipient.
    /// @param value The amount to send.
    function transfer(address to, uint256 value) external {
        uint256 oldBalanceFrom = balances[msg.sender];
        uint256 oldBalanceTo = balances[to];

        uint256 newBalanceFrom = oldBalanceFrom - value;
        balances[msg.sender] = newBalanceFrom;

        uint256 newBalanceTo = oldBalanceTo + value;
        balances[to] = newBalanceTo;

        _updateCheckpoint(msg.sender, oldBalanceFrom, newBalanceFrom);
        _updateCheckpoint(to, oldBalanceTo, newBalanceTo);
    }

    /// @dev Records the user's balance at this block number.
    /// @param user The address whose balance is updated.
    /// @param oldBalance The previous balance.
    /// @param newBalance The updated balance.
    function _updateCheckpoint(address user, uint256 oldBalance, uint256 newBalance) internal {
        balancesAt[user][block.timestamp] = newBalance;
        emit BalanceUpdated(user, oldBalance, newBalance);
    }
}
