// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @dev This contract represents a Battle Royale game where participants compete to become the "king" by achieving the lowest score.
///      Participants can challenge the current king by deploying their own challenger contract.
///      The challenger must return a non-empty response when called.
///      If the challenger's address is lower than the current king's challenger address, they dethrone the previous king and become the new king.
///      The rewards are distributed among the participants based on the time they held the king position.
contract BattleRoyale {
    uint256 public constant DURATION = 1 weeks;
    uint256 public constant TOTAL_REWARD = 10 ether;
    uint256 public immutable endTime;

    address public king;
    address public kingChallenger;
    uint256 public dethronedTime;

    constructor() payable {
        require(msg.value == TOTAL_REWARD);

        endTime = block.timestamp + DURATION;

        king = msg.sender;
        kingChallenger = address(type(uint160).max);
        dethronedTime = block.timestamp;
    }

    /// @dev Allows a participant to challenge the current king by giving their own challenger contract.
    ///      We expect participants to handle frontrunning risks themselves.
    /// @param challenger The address of the challenger's contract.
    function dethrone(address challenger) external {
        require(block.timestamp < endTime, "The game has ended");
        require(
            uint160(challenger) < uint160(kingChallenger),
            "Challenger's address must be lower than the current king's challenger address"
        );

        (bool success, bytes memory data) = challenger.staticcall("");
        require(success && data.length > 0, "Invalid challenger");

        address previousKing = king;
        uint256 previousKingReward = TOTAL_REWARD * (block.timestamp - dethronedTime) / DURATION;

        king = msg.sender;
        kingChallenger = challenger;
        dethronedTime = block.timestamp;

        // If the user can't receive the reward, it will be burned.
        previousKing.call{value: previousKingReward}("");
    }

    /// @dev Allows the current king to claim their reward at the end of the game.
    function claim() external {
        require(block.timestamp >= endTime, "The game has not ended");

        uint256 kingReward = TOTAL_REWARD * (endTime - dethronedTime) / DURATION;

        dethronedTime = endTime;

        (bool success,) = king.call{value: kingReward}("");
        require(success, "Transfer failed");
    }
}
