// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @dev Two parties deposit on a particular side and the owner decides which side is correct.
///      Owner's decision is based on some external factors irrelevant to this contract.
contract Resolver {
    enum Side {
        A,
        B
    }

    address public immutable owner = msg.sender;
    uint256 public immutable baseDeposit;
    uint256 public immutable reward;
    bool public declared;

    address[2] public sides;
    uint256[2] public partyDeposits;

    /// @param newBaseDeposit The deposit a party has to pay. Note that it is greater than the reward.
    constructor(uint256 newBaseDeposit) payable {
        require(newBaseDeposit >= msg.value, "Base deposit must be greater than the reward");
        reward = msg.value;
        baseDeposit = newBaseDeposit;
    }

    /// @dev Makes a deposit to one of the sides.
    /// @param side The side chosen by the party.
    function deposit(Side side) external payable {
        require(!declared, "The winner is already declared");
        require(sides[uint256(side)] == address(0), "Side already paid");
        require(msg.value > baseDeposit, "Should cover the base deposit");

        sides[uint256(side)] = msg.sender;
        partyDeposits[uint256(side)] = msg.value;
    }

    /// @dev Pays the reward to the winner. Reimburses the surplus deposit for both parties if there was one.
    /// @param winner The side that is eligible to a reward according to owner.
    function declareWinner(Side winner) external {
        require(!declared, "The winner is already declared");
        require(msg.sender == owner, "Only owner allowed");

        declared = true;

        // Pays the winner. Note that if no one put a deposit for the winning side, the reward will be burnt.
        (bool success,) = sides[uint256(winner)].call{value: reward}("");
        require(success, "Transfer failed");

        // Reimburse the surplus deposit if there was one.
        if (partyDeposits[0] > baseDeposit && sides[0] != address(0)) {
            (success,) = sides[0].call{value: partyDeposits[0] - baseDeposit}("");
            require(success, "Transfer failed");
        }

        if (partyDeposits[1] > baseDeposit && sides[1] != address(0)) {
            (success,) = sides[1].call{value: partyDeposits[1] - baseDeposit}("");
            require(success, "Transfer failed");
        }
    }
}
