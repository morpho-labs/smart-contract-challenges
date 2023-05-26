// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// These contracts are examples of contracts with bugs and vulnerabilities to practice your hacking skills.
// DO NOT USE THEM OR GET INSPIRATION FROM THEM TO MAKE CODE USED IN PRODUCTION.
// You are required to find vulnerabilities where an attacker harms someone else.
// Being able to destroy your own stuff is not a vulnerability and should be dealt with at the interface level.

/* Exercise 1 */

/// @dev Contract to store and redeem money.
contract Store {
    struct Safe {
        address owner;
        uint256 amount;
    }

    Safe[] public safes;

    /// @dev Stores some ETH.
    function store() external payable {
        safes.push(Safe({owner: msg.sender, amount: msg.value}));
    }

    /// @dev Takes back all the amount stored by the sender.
    function take() external {
        for (uint256 i; i < safes.length; ++i) {
            Safe storage safe = safes[i];
            if (safe.owner == msg.sender && safe.amount != 0) {
                uint256 amount = safe.amount;
                safe.amount = 0;

                (bool success,) = msg.sender.call{value: amount}("");
                require(success, "Transfer failed");
            }
        }
    }
}

/* Exercise 2 */

/// @dev Enables users to buy objects at discounted prices.
contract DiscountedBuy {
    uint256 public constant BASE_PRICE = 1 ether;
    mapping(address => uint256) public objectsBought;

    /// @dev Allows a user to buy an object by paying the appropriate price.
    /// @notice The price is calculated as `BASE_PRICE / (1 + objectsBought[msg.sender])`.
    function buy() external payable {
        require(msg.value * (1 + objectsBought[msg.sender]) == BASE_PRICE, "Incorrect payment amount");
        objectsBought[msg.sender]++;
    }

    /// @dev Calculates and returns the price of the next object to be purchased.
    /// @return The amount to be paid in wei.
    function price() external view returns (uint256) {
        return BASE_PRICE / (1 + objectsBought[msg.sender]);
    }
}

/* Exercise 3 */

/// @dev One party chooses Head or Tail and sends 1 ETH.
///      The next party sends 1 ETH and tries to guess what the first party chose.
///      If they succeed, they get 2 ETH, else the first party gets 2 ETH.
contract HeadOrTail {
    bool public chosen; // True if the choice has been made.
    bool public lastChoiceIsHead; // True if the choice is head.
    address public lastParty; // The last party who chose.

    /// @dev Must be sent 1 ETH.
    ///      Choose Head or Tail to be guessed by the other player.
    /// @param chooseHead True if Head was chosen, false if Tail was chosen.
    function choose(bool chooseHead) external payable {
        require(!chosen, "Choice already made");
        require(msg.value == 1 ether, "Incorrect payment amount");

        chosen = true;
        lastChoiceIsHead = chooseHead;
        lastParty = msg.sender;
    }

    /// @dev Guesses the choice of the first party and resolves the Head or Tail Game.
    /// @param guessHead The guess (Head or Tail) of the opposite party.
    function guess(bool guessHead) external payable {
        require(chosen, "Choice not made yet");
        require(msg.value == 1 ether, "Incorrect payment amount");

        (bool success,) = (guessHead == lastChoiceIsHead ? msg.sender : lastParty).call{value: 2 ether}("");
        require(success, "Transfer failed");
        chosen = false;
    }
}

/* Exercise 4 */

/// @dev Contract managing the storage and the redemption of ETH.
contract Vault {
    mapping(address => uint256) public balances;

    /// @dev Stores the ETH of the sender in the contract.
    function store() external payable {
        balances[msg.sender] += msg.value;
    }

    /// @dev Redeems the ETH of the sender in the contract.
    function redeem() external {
        (bool success,) = msg.sender.call{value: balances[msg.sender]}("");
        require(success, "Transfer failed");
        balances[msg.sender] = 0;
    }
}

/* Exercise 5 */

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

/* Exercise 6 */

/// @dev Contract for a simple token that can be sent.
contract SimpleToken {
    mapping(address => int256) public balances;

    /// @dev Creator starts with all the tokens.
    constructor() {
        balances[msg.sender] = 1000e18;
    }

    /// @dev Sends token.
    /// @param recipient The recipient.
    /// @param amount The amount to send.
    function sendToken(address recipient, int256 amount) external {
        balances[msg.sender] -= amount;
        balances[recipient] += amount;
    }
}

/* Exercise 7 */

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

/* Exercise 8 */

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

/* Exercise 9 */

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

/* Exercise 10 */

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

/* Exercise 11*/

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
        require(!isRegistered[name][surname][nonce], "This profile is already registered.");
        isRegistered[name][surname][nonce] = true;
        bytes32 id = keccak256(abi.encodePacked(name, surname, nonce));

        users[id] =
            User({account: msg.sender, timestamp: uint64(block.timestamp), name: name, surname: surname, nonce: nonce});
    }
}

/* Exercise 12 */

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

/* Exercise 13 */

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

/* Exercise 14 */

/// @dev This is a piggy bank.
///      The owner can deposit 1 ETH whenever they want.
///      They can only withdraw when the deposited amount reaches 10 ETH.
contract PiggyBank {
    address public immutable owner;

    /// @dev Sets the deployer as the owner
    constructor() {
        owner = msg.sender;
    }

    /// @dev Deposits 1 ETH in the smart contract
    function deposit() external payable {
        require(msg.sender == owner, "Only the owner can deposit");
        require(msg.value == 1 ether, "Deposit amount must be 1 ETH");
        require(address(this).balance <= 10 ether, "Deposit limit exceeded");
    }

    /// @dev Withdraws the entire smart contract balance
    function withdraw() external {
        require(msg.sender == owner, "Only the owner can withdraw");
        require(address(this).balance == 10 ether, "Cannot withdraw before reaching 10 ETH");

        (bool success,) = msg.sender.call{value: address(this).balance}("");
        require(success, "Transfer failed");
    }
}

/* Exercise 15 */

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

/* Exercise 16 */

/// @dev A contract for distributing rewards using Merkle proofs.
contract RewardsDistributor {
    uint256 public constant REWARD_AMOUNT = 1 ether;
    address public immutable ADMIN;
    bytes32 public immutable ROOT;

    mapping(bytes32 node => bool) public claimed;

    /// @notice Assumes that the deployer has provided a valid root hash, and sent the correct amount of ETH with the deployment.
    /// @param root The root hash of the Merkle tree used for reward distribution.
    constructor(bytes32 root) payable {
        ADMIN = msg.sender;
        ROOT = root;
    }

    /// @dev Verifies a Merkle proof proving the existence of a leaf in a Merkle tree. Assumes that each pair of leaves
    ///      and each pair of pre-images are sorted.
    /// @param proof Merkle proof containing sibling hashes on the branch from the leaf to the root of the Merkle tree
    /// @param root Merkle root
    /// @param leaf Leaf of Merkle tree
    /// @return A boolean indicating whether the proof is valid or not.
    function _verify(bytes32[] calldata proof, bytes32 root, bytes32 leaf) internal pure returns (bool) {
        bytes32 computedHash = leaf;

        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];

            if (computedHash < proofElement) {
                // Hash(current computed hash + current element of the proof)
                computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
            } else {
                // Hash(current element of the proof + current computed hash)
                computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
            }
        }

        // Check if the computed hash (root) is equal to the provided root
        return computedHash == root;
    }

    /// @dev Allows an address to claim a reward based on a provided nonce and Merkle proof.
    /// @param nonce A unique identifier for the reward claim, allowing multiple rewards to the same address.
    /// @param deadline The deadline until which the reward can be claimed.
    /// @param proof Merkle proof for validating the claim.
    function claim(uint256 nonce, uint96 deadline, bytes32[] calldata proof) external {
        claimOnBehalf(msg.sender, nonce, deadline, proof);
    }

    /// @dev Allows an address to claim rewards on behalf of another address based on a provided nonce and Merkle proof.
    /// @param onBehalf The address for which the rewards are being claimed.
    /// @param nonce A unique identifier for the reward claim, allowing multiple rewards to the same address.
    /// @param deadline The deadline until which the reward can be claimed.
    /// @param proof Merkle proof for validating the claim.
    function claimOnBehalf(address onBehalf, uint256 nonce, uint96 deadline, bytes32[] calldata proof) public {
        bytes32 node = keccak256(abi.encodePacked(onBehalf, nonce, deadline));

        require(!claimed[node], "Already claimed");
        require(_verify(proof, ROOT, node), "Invalid proof");

        claimed[node] = true;

        // Transfer the reward amount to the claimant or admin if the deadline has passed
        (bool success,) = (block.timestamp < deadline ? onBehalf : ADMIN).call{value: REWARD_AMOUNT}("");
        require(success, "Transfer failed");
    }
}

/* Exercise 17 */

/// @dev This contract enables users to buy and sell tokens using the x * y = k formula,
///      where tokens are used to purchase tickets.
///      The price of a ticket is the equivalent of `_ticketPriceInEth` Ether in token.
///      The objective for users is to purchase tickets, which can be used as an entry pass for an event or to gain access to a service.
contract Ticketing {
    address public immutable owner;
    uint256 public immutable ticketPriceInEth;
    uint256 public immutable virtualReserveEth;
    uint256 public immutable k;

    mapping(address => uint256) public balances;
    mapping(address => uint256) public tickets;

    /// @dev We assume that the values of the different parameters are big enough to minimize the impact of rounding errors.
    /// @param newTicketPriceInEth The price of a ticket in Ether.
    /// @param newVirtualReserveEth The virtual reserve of Ether in the contract.
    /// @param totalSupply The total supply of tokens.
    constructor(uint256 newTicketPriceInEth, uint256 newVirtualReserveEth, uint256 totalSupply) {
        require(newVirtualReserveEth > newTicketPriceInEth, "Virtual reserve must be greater than ticket price");

        owner = msg.sender;
        ticketPriceInEth = newTicketPriceInEth;
        virtualReserveEth = newVirtualReserveEth;
        k = newVirtualReserveEth * totalSupply;
        balances[address(this)] = totalSupply;
    }

    /// @notice Buy tokens by sending Ether.
    /// @dev The amount out is determined using the formula: (x + dx) * (y - dy) = k.
    /// @param amountOutMin The minimum amount of tokens expected to receive.
    /// @return amountOut The amount of tokens received.
    function buyToken(uint256 amountOutMin) external payable returns (uint256 amountOut) {
        amountOut = _reserveToken() - k / (_reserveEth() + msg.value);
        require(amountOut >= amountOutMin, "Insufficient tokens received");
        balances[address(this)] -= amountOut;
        balances[msg.sender] += amountOut;
    }

    /// @notice Sell tokens in exchange for Ether.
    /// @dev The amount out is determined using the formula: (x - dx) * (y + dy) = k.
    /// @param amountIn The amount of tokens to sell.
    /// @param amountOutMin The minimum amount of Ether expected to receive.
    /// @return amountOut The amount of Ether received.
    function sellToken(uint256 amountIn, uint256 amountOutMin) external returns (uint256 amountOut) {
        amountOut = _reserveEth() - k / (_reserveToken() + amountIn);
        require(amountOut >= amountOutMin, "Insufficient Ether received");
        balances[msg.sender] -= amountIn;
        balances[address(this)] += amountIn;

        (bool success,) = msg.sender.call{value: amountOut}("");
        require(success, "Transfer failed");
    }

    /// @notice Get the effective Ether balance available for token swaps.
    /// @dev This function calculates the effective Ether balance by subtracting the value sent in the current transaction and adding the virtual reserve.
    /// @return The effective Ether balance available for token swaps.
    function _reserveEth() internal view returns (uint256) {
        return address(this).balance - msg.value + virtualReserveEth;
    }

    /// @notice Get the effective token balance available for token swaps.
    /// @return The effective token balance available for token swaps.
    function _reserveToken() internal view returns (uint256) {
        return balances[address(this)];
    }

    /// @notice Get the current ticket price.
    /// @dev The price of a ticket is determined by how much tokens must be sold to obtain `_ticketPriceInEth` Ether.
    ///      Like in the function `sellToken`, the following formula is used: (x - dx) * (y + dy) = k.
    /// @return The current ticket price in Ether.
    function ticketPrice() public view returns (uint256) {
        return k / (_reserveEth() - ticketPriceInEth) - _reserveToken();
    }

    /// @notice Buy a ticket.
    /// @param maxPrice The maximum price the buyer is willing to pay for a ticket.
    function buyTicket(uint256 maxPrice) external {
        uint256 price = ticketPrice();
        require(price <= maxPrice, "Ticket price exceeds the maximum limit");
        balances[msg.sender] -= price;
        balances[owner] += price;
        tickets[msg.sender]++;
    }
}

/* Exercise 18 */

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

/* Exercise 19 */

/// @dev A contract for managing crowdfunding projects.
contract Crowdfunding {
    struct Project {
        address creator;
        uint256 deadline;
        uint256 targetAmount;
        uint256 totalAmountRaised;
        bool withdrawn;
        mapping(address => uint256) contributions;
    }

    Project[] public projects;

    /// @dev Create a new crowdfunding project.
    ///      The project creator specifies the deadline and target amount for the project.
    ///      Caller must be able to receive funds, otherwise, the funded amount will be lost.
    /// @param deadline The deadline for the project.
    /// @param targetAmount The target amount of funds to be raised for the project.
    /// @return projectIndex The index of the newly created project in the projects array.
    function createProject(uint256 deadline, uint256 targetAmount) external returns (uint256 projectIndex) {
        require(block.timestamp < deadline, "Deadline must be in the future");

        projectIndex = projects.length;
        projects.push();

        projects[projectIndex].creator = msg.sender;
        projects[projectIndex].deadline = deadline;
        projects[projectIndex].targetAmount = targetAmount;
    }

    /// @dev Contribute an amount of funds to the specified project.
    /// @param projectIndex The index of the project in the projects array.
    function contribute(uint256 projectIndex) external payable {
        Project storage project = projects[projectIndex];

        require(block.timestamp < project.deadline, "Deadline has passed");

        project.contributions[msg.sender] += msg.value;
        project.totalAmountRaised += msg.value;
    }

    /// @dev Withdraw funds from a successfully funded project.
    ///      The project creator can withdraw the funds raised if the target amount is reached before the deadline.
    ///      Caller must be able to receive funds, otherwise, the contributed amount will be lost.
    /// @param projectIndex The index of the project in the projects array.
    function withdrawFunds(uint256 projectIndex) external {
        Project storage project = projects[projectIndex];

        require(block.timestamp >= project.deadline, "Deadline has not passed");
        require(msg.sender == project.creator, "Only the project creator can withdraw funds");
        require(project.totalAmountRaised >= project.targetAmount, "Target amount not reached");
        require(!project.withdrawn, "Funds already withdrawn");

        project.withdrawn = true;
        (bool success,) = msg.sender.call{value: project.totalAmountRaised}("");
        require(success, "Transfer failed");
    }

    /// @dev Withdraw contributed funds if the project is not successfully funded.
    ///      Contributors can withdraw their contributions if the target amount is not reached before the deadline.
    /// @param projectIndex The index of the project in the projects array.
    function withdrawContribution(uint256 projectIndex) external {
        Project storage project = projects[projectIndex];

        require(block.timestamp >= project.deadline, "Deadline has not passed");
        require(project.totalAmountRaised < project.targetAmount, "Target amount reached");

        uint256 contribution = project.contributions[msg.sender];
        project.contributions[msg.sender] = 0;

        (bool success,) = msg.sender.call{value: contribution}("");
        require(success, "Transfer failed");
    }

    /// @dev Perform a series of transactions in a single call.
    /// @param transactions The array of transactions to be executed.
    /// @return results The results of each transaction in the same order as the input transactions.
    function batchTransactions(bytes[] calldata transactions) external payable returns (bytes[] memory results) {
        results = new bytes[](transactions.length);

        bool success;
        for (uint256 i = 0; i < transactions.length; i++) {
            (success, results[i]) = address(this).delegatecall(transactions[i]);
            require(success, "Delegatecall failed");
        }
    }
}
