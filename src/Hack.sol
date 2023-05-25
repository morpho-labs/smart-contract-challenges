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
    function store() public payable {
        safes.push(Safe({owner: msg.sender, amount: msg.value}));
    }

    /// @dev Takes back all the amount stored by the sender.
    function take() public {
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

/// @dev You can buy some objects.
///      Further purchases are discounted.
///      You need to pay basePrice / (1 + objectBought), where objectBought is the number of objects you previously bought.
contract DiscountedBuy {
    uint256 public basePrice = 1 ether;
    mapping(address => uint256) public objectBought;

    /// @dev Buy an object.
    function buy() public payable {
        require(msg.value * (1 + objectBought[msg.sender]) == basePrice);
        objectBought[msg.sender] += 1;
    }

    /// @dev Returns the price you'll need to pay.
    /// @return The amount you need to pay in wei.
    function price() public view returns (uint256) {
        return basePrice / (1 + objectBought[msg.sender]);
    }
}

/* Exercise 3 */

/// @dev One party chooses Head or Tail and sends 1 ETH.
///      The next party sends 1 ETH and tries to guess what the first party chose.
///      If they succeed, they get 2 ETH, else the first party gets 2 ETH.
contract HeadOrTail {
    bool public chosen; // True if the choice has been made.
    bool public lastChoiceHead; // True if the choice is head.
    address public lastParty; // The last party who chose.

    /// @dev Must be sent 1 ETH.
    ///      Choose Head or Tail to be guessed by the other player.
    /// @param _chooseHead True if Head was chosen, false if Tail was chosen.
    function choose(bool _chooseHead) public payable {
        require(!chosen);
        require(msg.value == 1 ether);

        chosen = true;
        lastChoiceHead = _chooseHead;
        lastParty = msg.sender;
    }

    /// @dev Guesses the choice of the first party and resolves the Head or Tail Game.
    /// @param _guessHead The guess (Head or Tail) of the opposite party.
    function guess(bool _guessHead) public payable {
        require(chosen);
        require(msg.value == 1 ether);

        (bool success,) = (_guessHead == lastChoiceHead ? msg.sender : lastParty).call{value: 2 ether}("");
        require(success, "Transfer failed");
        chosen = false;
    }
}

/* Exercise 4 */

/// @dev Contract managing the storage and the redemption of ETH.
contract Vault {
    mapping(address => uint256) public balances;

    /// @dev Stores the ETH of the sender in the contract.
    function store() public payable {
        balances[msg.sender] += msg.value;
    }

    /// @dev Redeems the ETH of the sender in the contract.
    function redeem() public {
        (bool success,) = msg.sender.call{value: balances[msg.sender]}("");
        require(success, "Transfer failed");
        balances[msg.sender] = 0;
    }
}

/* Exercise 5 */

/// @dev Contract for locking and unlocking funds using a commitment and password.
contract Locker {
    bytes32 commitment;

    /// @dev Locks the funds sent along with this transaction by setting the commitment.
    /// @param _commitment The commitment to lock the funds.
    function lock(bytes32 _commitment) external payable {
        require(_commitment != bytes32(0), "Invalid commitment");
        commitment = _commitment;
    }

    /// @dev Unlocks the funds by comparing the provided password with the commitment.
    /// @param _password The password to unlock the funds.
    function unlock(string calldata _password) external {
        require(keccak256(abi.encode(_password)) == commitment, "Invalid password");
        (bool success,) = msg.sender.call{value: address(this).balance}("");
        require(success, "Transfer failed");
    }
}

/* Exercise 6 */

/// @dev Contract for a simple token that can be sent.
contract SimpleToken {
    mapping(address => int256) public balances;

    /* CONSTRUCTOR */

    /// @dev Creator starts with all the tokens.
    constructor() {
        balances[msg.sender] += 1000e18;
    }

    /// @dev Sends token.
    /// @param _recipient The recipient.
    /// @param _amount The amount to send.
    function sendToken(address _recipient, int256 _amount) public {
        balances[msg.sender] -= _amount;
        balances[_recipient] += _amount;
    }
}

/* Exercise 7 */

/// @dev Contract for a simple token that can be exchanged through a bonded curve and sent.
/// @notice We assume that order frontrunning is fine.
contract LinearBondedCurve {
    mapping(address => uint256) public balances;
    uint256 public totalSupply;

    /// @dev Buys token. The price is linear to the total supply.
    function buy() public payable {
        uint256 tokenToReceive = (1e18 * msg.value) / (1e18 + totalSupply);
        balances[msg.sender] += tokenToReceive;
        totalSupply += tokenToReceive;
    }

    /// @dev Sells token. The price of it is linear to the supply.
    /// @param _amount The amount of tokens to sell.
    function sell(uint256 _amount) public {
        uint256 ethToReceive = ((1e18 + totalSupply) * _amount) / 1e18;
        balances[msg.sender] -= _amount;
        totalSupply -= _amount;
        (bool success,) = msg.sender.call{value: ethToReceive}("");
        require(success, "Transfer failed");
    }

    /// @dev Sends token.
    /// @param _recipient The recipient.
    /// @param _amount The amount to send.
    function sendToken(address _recipient, uint256 _amount) public {
        balances[msg.sender] -= _amount;
        balances[_recipient] += _amount;
    }
}

/* Exercise 8 */

/// @dev Contract to create coffers, deposit and withdraw money from them.
contract Coffers {
    struct Coffer {
        uint256 nbSlots;
        mapping(uint256 => uint256) slots;
    }

    mapping(address => Coffer) public coffers;

    /// @dev Creates coffers.
    /// @param _slots The amount of slots the coffer will have.
    function createCoffer(uint256 _slots) external {
        Coffer storage coffer = coffers[msg.sender];
        require(coffer.nbSlots == 0, "Coffer already created");
        coffer.nbSlots = _slots;
    }

    /// @dev Deposits money into one's coffer slot.
    /// @param _owner The owner of the coffer.
    /// @param _slot The slot to deposit money into.
    function deposit(address _owner, uint256 _slot) external payable {
        Coffer storage coffer = coffers[_owner];
        require(_slot < coffer.nbSlots);
        coffer.slots[_slot] += msg.value;
    }

    /// @dev Withdraws all the money from one's coffer slot.
    /// @param _slot The slot to withdraw money from.
    function withdraw(uint256 _slot) external {
        Coffer storage coffer = coffers[msg.sender];
        require(_slot < coffer.nbSlots);
        uint256 ethToReceive = coffer.slots[_slot];
        coffer.slots[_slot] = 0;
        (bool success,) = msg.sender.call{value: ethToReceive}("");
        require(success, "Transfer failed");
    }

    /// @dev Closes an account withdrawing all the money.
    function closeAccount() external {
        Coffer storage coffer = coffers[msg.sender];
        uint256 amountToSend;
        for (uint256 i = 0; i < coffer.nbSlots; ++i) {
            amountToSend += coffer.slots[i];
        }
        coffer.nbSlots = 0;
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

    address public owner = msg.sender;
    address[2] public sides;
    uint256 public baseDeposit;
    uint256 public reward;
    bool public declared;
    uint256[2] public partyDeposits;

    /* CONSTRUCTOR */

    /// @param _baseDeposit The deposit a party has to pay. Note that it is greater than the reward.
    constructor(uint256 _baseDeposit) payable {
        reward = msg.value;
        baseDeposit = _baseDeposit;
    }

    /// @dev Makes a deposit to one of the sides.
    /// @param _side The side chosen by the party.
    function deposit(Side _side) public payable {
        require(!declared, "The winner is already declared");
        require(sides[uint256(_side)] == address(0), "Side already paid");
        require(msg.value > baseDeposit, "Should cover the base deposit");
        sides[uint256(_side)] = msg.sender;
        partyDeposits[uint256(_side)] = msg.value;
    }

    /// @dev Pays the reward to the winner. Reimburses the surplus deposit for both parties if there was one.
    /// @param _winner The side that is eligible to a reward according to owner.
    function declareWinner(Side _winner) public {
        require(declared != true, "Rewards already paid");
        require(msg.sender == owner, "Only owner allowed");
        declared = true;

        uint256 rewardSent = reward;

        // Pays the winner. Note that if no one put a deposit for the winning side, the reward will be burnt.
        (bool success,) = sides[uint256(_winner)].call{value: rewardSent}("");
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
///      Note that simply being registered does not confer any right.
contract Registry {
    struct User {
        address payable regAddress;
        uint64 timestamp;
        bool registered;
        string name;
        string surname;
        uint256 nonce;
    }

    // Nonce is used so the contract can add multiple profiles with the same first name and last name.
    mapping(string => mapping(string => mapping(uint256 => bool))) public isRegistered; // name -> surname -> nonce -> registered/not registered.
    mapping(bytes32 => User) public users; // User isn't identified by address but by his ID, since the same person can have multiple addresses.

    /// @dev Adds yourself to the registry.
    /// @param _name The first name of the user.
    /// @param _surname The last name of the user.
    /// @param _nonce An arbitrary number to allow multiple users with the same first and last name.
    function register(string calldata _name, string calldata _surname, uint256 _nonce) public {
        require(!isRegistered[_name][_surname][_nonce], "This profile is already registered");
        isRegistered[_name][_surname][_nonce] = true;
        bytes32 ID = keccak256(abi.encodePacked(_name, _surname, _nonce));
        User storage user = users[ID];
        user.regAddress = payable(msg.sender);
        user.timestamp = uint64(block.timestamp);
        user.registered = true;
        user.name = _name;
        user.surname = _surname;
        user.nonce = _nonce;
    }
}

/* Exercise 12 */

/// @dev A Token contract that keeps a record of the users past balances.
contract SnapShotToken {
    mapping(address => uint256) public balances;
    mapping(address => mapping(uint256 => uint256)) public balanceAt;

    event BalanceUpdated(address indexed user, uint256 oldBalance, uint256 newBalance);

    /// @dev Buys token at the price of 1ETH/token.
    function buyToken() public payable {
        uint256 _balance = balances[msg.sender];
        uint256 _newBalance = _balance + msg.value / 1 ether;
        balances[msg.sender] = _newBalance;

        _updateCheckpoint(msg.sender, _balance, _newBalance);
    }

    /// @dev Transfers tokens.
    /// @param _to The recipient.
    /// @param _value The amount to send.
    function transfer(address _to, uint256 _value) public {
        uint256 _balancesFrom = balances[msg.sender];
        uint256 _balancesTo = balances[_to];

        uint256 _balancesFromNew = _balancesFrom - _value;
        balances[msg.sender] = _balancesFromNew;

        uint256 _balancesToNew = _balancesTo + _value;
        balances[_to] = _balancesToNew;

        _updateCheckpoint(msg.sender, _balancesFrom, _balancesFromNew);
        _updateCheckpoint(_to, _balancesTo, _balancesToNew);
    }

    /// @dev Records the users balance at this blocknumber
    /// @param _user The address who's balance is updated.
    /// @param _oldBalance The previous balance.
    /// @param _newBalance The updated balance.
    function _updateCheckpoint(address _user, uint256 _oldBalance, uint256 _newBalance) internal {
        balanceAt[_user][block.timestamp] = _newBalance;
        emit BalanceUpdated(_user, _oldBalance, _newBalance);
    }
}

/* Exercise 13 */

/// @dev Each player tries to guess the average of all the player's revealed answers combined.
///      They must pay 1 ETH to play.
///      The winners are those who are the nearest from the average.
///      Note that some players may not reveal and use multiple accounts, this is part of the game and can be used tactically.
///      Also note that waiting the last minute to reveal is also part of the game and can be used tactically (but it would probably cost a lot of gas).
contract GuessTheAverage {
    uint256 public immutable start; // Beginning of the game.
    uint256 public immutable commitDuration; // Duration of the Commit Period.
    uint256 public immutable revealDuration; // Duration of the Reveal Period.
    uint256 public cursorWinner; // Cursor of the last winner.
    uint256 public cursorDistribute; // Cursor of the last distribution of rewards.
    uint256 public lastDifference; // Last best difference between a guess and the average.
    uint256 public average; // Average to guess.
    uint256 public totalBalance; // Total balance of the contract.
    uint256 public numberOfLosers; // Number of losers in the winners list.
    Stage public currentStage; // Current Stage.

    enum Stage {
        CommitAndRevealPeriod,
        AverageCalculated,
        WinnersFound,
        Distributed
    }

    struct Player {
        uint256 playerIndex; // Index of the player in the guesses list.
        bool hasGuessed; // Whether the player has guessed or not.
        bool hasReveal; // Whether the player has revealed or not.
        bytes32 commitment; // commitment of the player.
    }

    uint256[] public guesses; // List of player's guesses.
    address[] public winners; // List of winners to reward.

    mapping(address => Player) public players; // Maps an address to its respective Player status.
    mapping(uint256 => address) public indexToPlayer; // Maps a guess index to the player who made the guess.

    /* CONSTRUCTOR */

    constructor(uint32 _commitDuration, uint32 _revealDuration) {
        start = block.timestamp;
        commitDuration = _commitDuration;
        revealDuration = _revealDuration;
    }

    /// @dev Adds the guess for the user.
    /// @param _commitment The commitment of the user under the form of keccak256(abi.encode(msg.sender, _number, _blindingFactor) where the blinding factor is a bytes32.
    function guess(bytes32 _commitment) public payable {
        Player storage player = players[msg.sender];
        require(!player.hasGuessed, "Player has already guessed");
        require(msg.value == 1 ether, "Player must send exactly 1 ETH");
        require(
            block.timestamp >= start && block.timestamp <= start + commitDuration,
            "Commit period must have begun and not ended"
        );

        // Store the commitment.
        player.hasGuessed = true;
        player.commitment = _commitment;
    }

    /// @dev Reveals the guess for the user.
    /// @param _number The number guessed.
    /// @param _blindingFactor Bytes that has been used for the commitment to blind the guess.
    function reveal(uint256 _number, bytes32 _blindingFactor) public {
        require(
            block.timestamp >= start + commitDuration && block.timestamp < start + commitDuration + revealDuration,
            "Reveal period must have begun and not ended"
        );
        Player storage player = players[msg.sender];
        require(!player.hasReveal, "Player has already revealed");
        require(player.hasGuessed, "Player must have guessed");
        // Check the hash to prove the player's honesty
        require(keccak256(abi.encode(msg.sender, _number, _blindingFactor)) == player.commitment, "Invalid hash");

        // Update player and guesses.
        player.hasReveal = true;
        average += _number;
        indexToPlayer[guesses.length] = msg.sender;
        guesses.push(_number);
        player.playerIndex = guesses.length;
    }

    /// @dev Finds winners among players who have revealed their guess.
    /// @param _count The number of transactions to execute. Executes until the end if set to "0" or number higher than number of transactions in the list.
    function findWinners(uint256 _count) public {
        require(block.timestamp >= start + commitDuration + revealDuration, "Reveal period must have ended");
        require(currentStage < Stage.WinnersFound);
        // If we don't have calculated the average yet, we calculate it.
        if (currentStage < Stage.AverageCalculated) {
            average /= guesses.length;
            currentStage = Stage.AverageCalculated;
            totalBalance = address(this).balance;
            cursorWinner += 1;
        }
        // If there is no winner we push the first player into the winners list to initialize it.
        if (winners.length == 0) {
            winners.push(indexToPlayer[0]);
            // Avoid overflow.
            if (guesses[0] > average) lastDifference = guesses[0] - average;
            else lastDifference = average - guesses[0];
        }
        uint256 i = cursorWinner;
        for (; i < guesses.length && (_count == 0 || i < cursorWinner + _count); i++) {
            uint256 difference;
            // Avoid overflow.
            if (guesses[i] > average) difference = guesses[i] - average;
            else difference = average - guesses[i];
            // Compare difference with the latest lowest difference.
            if (difference < lastDifference) {
                // Add winner and update lastDifference.
                cursorDistribute = numberOfLosers = winners.length;
                winners.push(indexToPlayer[i]);
                lastDifference = difference;
            } else if (difference == lastDifference) {
                winners.push(indexToPlayer[i]);
            }
            // If we have passed through the entire array, update currentStage.
        }
        if (i == guesses.length) currentStage = Stage.WinnersFound;
        // Update the cursor in case we haven't finished going through the list.
        cursorWinner += _count;
    }

    /// @dev Distributes rewards to winners.
    /// @param _count The number of transactions to execute. Executes until the end if set to "0" or number higher than number of winners in the list.
    function distribute(uint256 _count) public {
        require(currentStage == Stage.WinnersFound, "Winners must have been found");

        while (cursorDistribute < winners.length && _count != 0) {
            // Send ether to the winners. Do not block if one of the account cannot receive ETH.
            winners[cursorDistribute++].call{value: totalBalance / (winners.length - numberOfLosers)}("");
            _count--;
        }

        if (cursorDistribute == winners.length - 1) currentStage = Stage.Distributed;
    }
}

/* Exercise 14 */

/// @dev This is a piggy bank.
///      The owner can deposit 1 ETH whenever he wants.
///      He can only withdraw when the deposited amount reaches 10 ETH.
contract PiggyBank {
    address public owner;

    /* CONSTRUCTOR */

    /// @dev Sets msg.sender as owner
    constructor() {
        owner = msg.sender;
    }

    /// @dev Deposits 1 ETH in the smart contract
    function deposit() public payable {
        require(msg.sender == owner && msg.value == 1 ether && address(this).balance <= 10 ether);
    }

    /// @dev Withdraws the entire smart contract balance
    function withdrawAll() public {
        require(msg.sender == owner && address(this).balance == 10 ether);
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

    /* CONSTRUCTOR */

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
    address public immutable _owner;
    uint256 public immutable _ticketPriceInEth;
    uint256 public immutable _virtualReserveEth;
    uint256 public immutable _k;

    mapping(address => uint256) public balances;
    mapping(address => uint256) public tickets;

    /// @dev We assume that the values of the different parameters are big enough to minimize the impact of rounding errors.
    /// @param ticketPriceInEth The price of a ticket in Ether.
    /// @param virtualReserveEth The virtual reserve of Ether in the contract.
    /// @param totalSupply The total supply of tokens.
    constructor(uint256 ticketPriceInEth, uint256 virtualReserveEth, uint256 totalSupply) {
        require(virtualReserveEth > ticketPriceInEth, "Virtual reserve must be greater than ticket price");

        _owner = msg.sender;
        _ticketPriceInEth = ticketPriceInEth;
        _virtualReserveEth = virtualReserveEth;
        _k = virtualReserveEth * totalSupply;
        balances[address(this)] = totalSupply;
    }

    /// @notice Buy tokens by sending Ether.
    /// @dev The amount out is determined using the formula: (x + dx) * (y - dy) = k.
    /// @param amountOutMin The minimum amount of tokens expected to receive.
    /// @return amountOut The amount of tokens received.
    function buyToken(uint256 amountOutMin) external payable returns (uint256 amountOut) {
        amountOut = reserveToken() - _k / (reserveEth() + msg.value);
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
        amountOut = reserveEth() - _k / (reserveToken() + amountIn);
        require(amountOut >= amountOutMin, "Insufficient Ether received");
        balances[msg.sender] -= amountIn;
        balances[address(this)] += amountIn;

        (bool success,) = msg.sender.call{value: amountOut}("");
        require(success, "Transfer failed");
    }

    /// @notice Get the effective Ether balance available for token swaps.
    /// @dev This function calculates the effective Ether balance by subtracting the value sent in the current transaction and adding the virtual reserve.
    /// @return The effective Ether balance available for token swaps.
    function reserveEth() internal view returns (uint256) {
        return address(this).balance - msg.value + _virtualReserveEth;
    }

    /// @notice Get the effective token balance available for token swaps.
    /// @return The effective token balance available for token swaps.
    function reserveToken() internal view returns (uint256) {
        return balances[address(this)];
    }

    /// @notice Get the current ticket price.
    /// @dev The price of a ticket is determined by how much tokens must be sold to obtain `_ticketPriceInEth` Ether.
    ///      Like in the function `sellToken`, the following formula is used: (x - dx) * (y + dy) = k.
    /// @return The current ticket price in Ether.
    function ticketPrice() public view returns (uint256) {
        return _k / (reserveEth() - _ticketPriceInEth) - reserveToken();
    }

    /// @notice Buy a ticket.
    /// @param maxPrice The maximum price the buyer is willing to pay for a ticket.
    function buyTicket(uint256 maxPrice) external {
        uint256 price = ticketPrice();
        require(price <= maxPrice, "Ticket price exceeds the maximum limit");
        balances[msg.sender] -= price;
        balances[_owner] += price;
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

    address public kingAddress;
    address public kingChallenger;
    uint256 public dethronedTime;

    constructor() payable {
        require(msg.value == TOTAL_REWARD);

        endTime = block.timestamp + DURATION;

        kingAddress = msg.sender;
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

        address previousKing = kingAddress;
        uint256 previousKingReward = TOTAL_REWARD * (block.timestamp - dethronedTime) / DURATION;

        kingAddress = msg.sender;
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

        (bool success,) = kingAddress.call{value: kingReward}("");
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
