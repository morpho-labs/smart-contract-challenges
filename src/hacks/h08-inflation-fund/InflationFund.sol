// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @dev Contract of a fund that follows inflation through an index.
contract InflationFund {
    uint256 totalSupply;
    mapping(address => uint256) public scaledBalances;
    uint256 public inflationIndex = 1e16;

    /// @dev Provides ethers to the contract and updates the index to follow inflation.
    /// @param newIndex The new index for the fund.
    function updateIndex(uint256 newIndex) external payable {
        require(newIndex >= inflationIndex, "Inflation");
        require(msg.value >= (newIndex - inflationIndex) * totalSupply, "Not enough ethers provided");
        inflationIndex = newIndex;
    }

    /// @dev Deposits some ethers to the inflation fund.
    function deposit() external payable {
        uint256 toAdd = msg.value / inflationIndex;
        scaledBalances[msg.sender] += toAdd;
        totalSupply += toAdd;
    }

    /// @dev Withdraws some ethers of the inflation fund.
    /// @param amount The amount that the user wants to withdraw.
    function withdraw(uint256 amount) external {
        uint256 toRemove = amount / inflationIndex;
        scaledBalances[msg.sender] -= toRemove;
        totalSupply -= toRemove;
        (bool success,) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");
    }
}
