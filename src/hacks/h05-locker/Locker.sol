// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @dev Contract for locking and unlocking funds using a commitment and password.
contract Locker {
    bytes32 internal _commitment;

    /// @dev Locks the funds sent along with this transaction by setting the commitment.
    /// @param commitment The commitment to lock the funds.
    function lock(bytes32 commitment) external payable {
        require(_commitment != bytes32(0), "Invalid commitment");
        _commitment = commitment;
    }

    /// @dev Unlocks the funds by comparing the provided password with the commitment.
    /// @param password The password to unlock the funds.
    function unlock(string calldata password) external {
        require(keccak256(abi.encode(password)) == _commitment, "Invalid password");
        (bool success,) = msg.sender.call{value: address(this).balance}("");
        require(success, "Transfer failed");
    }
}
