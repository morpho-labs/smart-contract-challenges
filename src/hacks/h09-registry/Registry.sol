// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @dev Contract for users to register. It will be used by other contracts to attach rights to those users (rights will be linked to user IDs).
///      Note that simply being registered does not confer any rights.
contract Registry {
    struct User {
        address account;
        uint64 timestamp;
        string name;
        string surname;
        uint256 nonce;
    }

    // Nonce is used so the contract can add multiple profiles with the same first name and last name.
    mapping(string => mapping(string => mapping(uint256 => bool))) public isRegistered;
    // Users aren't identified by address but by their IDs, since the same person can have multiple addresses.
    mapping(bytes32 => User) public users;

    /// @dev Adds yourself to the registry.
    /// @param name The first name of the user.
    /// @param surname The last name of the user.
    /// @param nonce An arbitrary number to allow multiple users with the same first and last name.
    function register(string calldata name, string calldata surname, uint256 nonce) external {
        require(!isRegistered[name][surname][nonce], "This profile is already registered");
        isRegistered[name][surname][nonce] = true;
        bytes32 id = keccak256(abi.encodePacked(name, surname, nonce));

        users[id] =
            User({account: msg.sender, timestamp: uint64(block.timestamp), name: name, surname: surname, nonce: nonce});
    }
}
