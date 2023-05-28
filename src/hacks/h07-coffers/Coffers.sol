// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @dev Contract to create coffers, deposit and withdraw money from them.
contract Coffers {
    struct Coffer {
        uint256 numberOfSlots;
        mapping(uint256 => uint256) slots;
    }

    mapping(address => Coffer) public coffers;

    /// @dev Creates a coffer with the specified number of slots for the caller.
    /// @param numberOfSlots The number of slots the coffer will have.
    function createCoffer(uint256 numberOfSlots) external {
        Coffer storage coffer = coffers[msg.sender];
        require(coffer.numberOfSlots == 0, "Coffer already created");
        coffer.numberOfSlots = numberOfSlots;
    }

    /// @dev Deposits money into the specified coffer slot.
    /// @param owner The owner of the coffer.
    /// @param slot The slot to deposit money into.
    function deposit(address owner, uint256 slot) external payable {
        Coffer storage coffer = coffers[owner];
        require(slot < coffer.numberOfSlots, "Invalid slot");
        coffer.slots[slot] += msg.value;
    }

    /// @dev Withdraws all the money from the specified coffer slot.
    /// @param slot The slot to withdraw money from.
    function withdraw(uint256 slot) external {
        Coffer storage coffer = coffers[msg.sender];
        require(slot < coffer.numberOfSlots, "Invalid slot");
        uint256 ethToReceive = coffer.slots[slot];
        coffer.slots[slot] = 0;
        (bool success,) = msg.sender.call{value: ethToReceive}("");
        require(success, "Transfer failed");
    }

    /// @dev Closes the coffer and withdraws all the money from all slots.
    function closeCoffer() external {
        Coffer storage coffer = coffers[msg.sender];
        uint256 amountToSend;
        for (uint256 i = 0; i < coffer.numberOfSlots; ++i) {
            amountToSend += coffer.slots[i];
        }
        coffer.numberOfSlots = 0;
        (bool success,) = msg.sender.call{value: amountToSend}("");
        require(success, "Transfer failed");
    }
}
