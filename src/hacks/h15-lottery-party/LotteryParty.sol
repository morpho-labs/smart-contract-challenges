// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @dev This is a game where an Owner considered as TRUSTED can set many lotteries with rewards.
///      The Owner chooses the winning number randomly off-chain. It should be within the range [0, ticketNumber].
///      Frontrunning the reveal of the winning number is impossible as the owner will see only the ticket number of the previous block.
///      The users can propose new lotteries but it's up to the Owner to fund them.
///      The Owner can clear the lottery to create fresh new ones.
contract LotteryParty {
    struct Lottery {
        uint256 ticketNumber;
        uint256 rewards;
        uint256 winningNumber;
        mapping(address => uint256[]) ticketDistribution;
    }

    address public owner;
    Lottery[] public lotteries;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /// @dev Creates new lotteries.
    /// @param numberOfLotteries The number of lotteries to create.
    function createNewLotteries(uint256 numberOfLotteries) external {
        for (uint256 i = 0; i < numberOfLotteries; i++) {
            lotteries.push();
        }
    }

    /// @dev Buys a ticket for a participant.
    /// @param lotteryIndex The index of the round concerned.
    function buyTicketForLottery(uint256 lotteryIndex) external payable {
        require(msg.value == 1 ether, "wrong value");
        uint256 ticketNumber = ++lotteries[lotteryIndex].ticketNumber;
        lotteries[lotteryIndex].ticketDistribution[msg.sender].push(ticketNumber);
    }

    /// @dev Set the reward at a specific round.
    /// @param lotteryIndex The index of the round concerned by the reward.
    function setRewardsAtRound(uint256 lotteryIndex) external payable onlyOwner {
        require(lotteries[lotteryIndex].rewards == 0);
        lotteries[lotteryIndex].rewards = msg.value;
    }

    /// @dev Set the winning number. It is chosen randomly off-chain by the trusted owner.
    /// @param lotteryIndex The index of the round concerned.
    /// @param winningNumber The winning number of the lottery.
    function setWinningNumberAtRound(uint256 lotteryIndex, uint256 winningNumber) external onlyOwner {
        require(winningNumber <= lotteries[lotteryIndex].ticketNumber, "Incorrect winning ticket");
        require(winningNumber != 0, "Incorrect winning ticket");
        lotteries[lotteryIndex].winningNumber = winningNumber;
    }

    /// @dev Withdraws rewards of a round.
    /// @param lotteryIndex The index of the round concerned.
    function withdrawRewards(uint256 lotteryIndex) external {
        uint256 winningTicket = lotteries[lotteryIndex].winningNumber;
        require(winningTicket != 0, "Incorrect winning ticket");

        uint256[] memory numbers = lotteries[lotteryIndex].ticketDistribution[msg.sender];

        uint256 amount = lotteries[lotteryIndex].rewards;
        lotteries[lotteryIndex].rewards = 0;

        for (uint256 i = 0; i < numbers.length; i++) {
            if (numbers[i] == winningTicket) {
                (bool success,) = msg.sender.call{value: amount}("");
                require(success, "Transfer failed");
                break;
            }
        }
    }

    /// @dev Delete the selected round.
    /// @param lotteryIndex The index of the round concerned.
    function clearRound(uint256 lotteryIndex) external onlyOwner {
        if (lotteries[lotteryIndex].rewards == 0) {
            delete lotteries[lotteryIndex];
        }
    }

    /// @dev Withdraws all the ethers to owner's address.
    function withdrawETH() external onlyOwner {
        uint256 length = lotteries.length;
        uint256 reward;
        for (uint256 i; i < length; ++i) {
            reward += lotteries[i].rewards;
        }
        (bool success,) = msg.sender.call{value: address(this).balance - reward}("");
        require(success, "Transfer failed");
    }
}
