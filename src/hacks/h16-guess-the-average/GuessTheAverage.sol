// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @dev Each player tries to guess the average of all the players' revealed answers combined.
///      They must pay 1 ETH to play.
///      The winners are those who are nearest to the average.
///      Note that some players may not reveal and use multiple accounts; this is part of the game and can be used tactically.
///      Also note that waiting until the last minute to reveal is also part of the game and can be used tactically (but it would probably cost a lot of gas).
contract GuessTheAverage {
    enum Stage {
        CommitAndRevealPeriod,
        AverageCalculated,
        WinnersFound,
        Distributed
    }

    struct Player {
        address player;
        uint256 guess;
    }

    uint256 public immutable start; // Beginning of the game.
    uint256 public immutable commitDuration; // Duration of the Commit Period.
    uint256 public immutable revealDuration; // Duration of the Reveal Period.

    uint256 public cursorWinner; // First index of `players` not treated in `findWinner`.
    uint256 public cursorDistribute; // First index of `pretendants` not treated in `distribute`.
    uint256 public lastDifference; // Last best difference between a guess and the average.
    uint256 public average; // Average to guess.
    uint256 public winnerReward; // Reward for a single winner.

    Stage public currentStage; // Current Stage.

    Player[] public players; // List of players who have participated.
    address[] public pretendants; // List of participants who may be eligible for winning.

    mapping(address => bytes32) public commitments; // Mapping of players to their commitments.

    /// @param newCommitDuration The duration of the commit period.
    /// @param newRevealDuration The duration of the reveal period.
    constructor(uint256 newCommitDuration, uint256 newRevealDuration) {
        start = block.timestamp;
        commitDuration = newCommitDuration;
        revealDuration = newRevealDuration;
    }

    /// @dev Adds the guess for the user.
    /// @param commitment The commitment of the user under the form of `keccak256(abi.encode(msg.sender, number, blindingFactor))`, where the blinding factor is a bytes32.
    function guess(bytes32 commitment) external payable {
        require(commitment != bytes32(0), "Commitment must not be zero");
        require(commitments[msg.sender] == bytes32(0), "Player has already guessed");
        require(msg.value == 1 ether, "Player must send exactly 1 ETH");
        require(
            block.timestamp >= start && block.timestamp <= start + commitDuration,
            "Commit period must have begun and not ended"
        );

        commitments[msg.sender] = commitment;
    }

    /// @dev Reveals the guess for the user.
    /// @param number The number guessed.
    /// @param blindingFactor Bytes that have been used for the commitment to blind the guess.
    function reveal(uint256 number, bytes32 blindingFactor) external {
        require(
            block.timestamp >= start + commitDuration && block.timestamp < start + commitDuration + revealDuration,
            "Reveal period must have begun and not ended"
        );

        bytes32 commitment = commitments[msg.sender];
        commitments[msg.sender] = bytes32(0);

        require(commitment != bytes32(0), "Player must have guessed");
        // Check the hash to prove the player's honesty.
        require(keccak256(abi.encode(msg.sender, number, blindingFactor)) == commitment, "Invalid hash");

        average += number;
        players.push(Player({player: msg.sender, guess: number}));
    }

    /// @dev Finds winners among players who have revealed their guess.
    /// @param count The number of transactions to execute; executes until the end if set to "0" or a number higher than the number of transactions in the list.
    function findWinners(uint256 count) external {
        require(block.timestamp >= start + commitDuration + revealDuration, "Reveal period must have ended");
        require(currentStage < Stage.WinnersFound, "Winners must not have been found yet");

        // If we haven't calculated the average yet, we calculate it.
        if (currentStage < Stage.AverageCalculated) {
            average /= players.length;
            lastDifference = type(uint256).max;
            currentStage = Stage.AverageCalculated;
        }

        while (cursorWinner < players.length && count > 0) {
            Player storage player = players[cursorWinner];

            // Avoid overflow.
            uint256 difference = player.guess > average ? player.guess - average : average - player.guess;

            // Compare the difference with the latest lowest difference.
            if (difference < lastDifference) {
                cursorDistribute = pretendants.length;
                pretendants.push(player.player);
                lastDifference = difference;
            } else if (difference == lastDifference) {
                pretendants.push(player.player);
            }

            cursorWinner++;
            count--;
        }

        // If we have passed through the entire array, update currentStage.
        if (cursorWinner == players.length) {
            winnerReward = address(this).balance / (pretendants.length - cursorDistribute);
            currentStage = Stage.WinnersFound;
        }
    }

    /// @dev Distributes rewards to winners.
    /// @param count The number of transactions to execute; executes until the end if set to "0" or a number higher than the number of winners in the list.
    function distribute(uint256 count) external {
        require(currentStage == Stage.WinnersFound, "Winners must have been found");

        // Send ether to the winners. Do not block if one of the accounts cannot receive ETH.
        while (cursorDistribute < pretendants.length && count > 0) {
            pretendants[cursorDistribute++].call{value: winnerReward}("");
            count--;
        }

        if (cursorDistribute == pretendants.length) currentStage = Stage.Distributed;
    }
}
