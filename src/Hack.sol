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
                payable(msg.sender).transfer(amount);
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
    address payable public lastParty; // The last party who chose.

    /// @dev Must be sent 1 ETH.
    ///      Choose Head or Tail to be guessed by the other player.
    /// @param _chooseHead True if Head was chosen, false if Tail was chosen.
    function choose(bool _chooseHead) public payable {
        require(!chosen);
        require(msg.value == 1 ether);

        chosen = true;
        lastChoiceHead = _chooseHead;
        lastParty = payable(msg.sender);
    }

    /// @dev Guesses the choice of the first party and resolves the Head or Tail Game.
    /// @param _guessHead The guess (Head or Tail) of the opposite party.
    function guess(bool _guessHead) public payable {
        require(chosen);
        require(msg.value == 1 ether);

        if (_guessHead == lastChoiceHead) payable(msg.sender).transfer(2 ether);
        else lastParty.transfer(2 ether);

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
        require(success);
        balances[msg.sender] = 0;
    }
}

/* Exercise 5 */

/// @dev One party chooses Head or Tail and sends 1 ETH.
///      The next party sends 1 ETH and tries to guess what the first party chose.
///      If they succeed, they get 2 ETH, else the first party gets 2 ETH.
contract HeadTail {
    address payable public partyA;
    address payable public partyB;
    bytes32 public commitmentA;
    bool public chooseHeadB;
    uint256 public timeB;

    /* CONSTRUCTOR */

    /// @param _commitmentA is the result of the following command: keccak256(abi.encode(chooseHead,randomNumber)).
    constructor(bytes32 _commitmentA) payable {
        require(msg.value == 1 ether);

        commitmentA = _commitmentA;
        partyA = payable(msg.sender);
    }

    /// @dev Guesses the choice of party A.
    /// @param _chooseHead True if the guess is Head, false otherwise.
    function guess(bool _chooseHead) public payable {
        require(msg.value == 1 ether);
        require(partyB == address(0));

        chooseHeadB = _chooseHead;
        timeB = block.timestamp;
        partyB = payable(msg.sender);
    }

    /// @dev Reveals the committed value and sends ETH to the winner.
    /// @param _chooseHead True if Head was chosen, false otherwise.
    /// @param _randomNumber The random number chosen to obfuscate the commitment.
    function resolve(bool _chooseHead, uint256 _randomNumber) public {
        require(msg.sender == partyA);
        require(keccak256(abi.encode(_chooseHead, _randomNumber)) == commitmentA);
        require(address(this).balance >= 2 ether);

        if (_chooseHead == chooseHeadB) partyB.transfer(2 ether);
        else partyA.transfer(2 ether);
    }

    /// @dev Time out party A if it takes more than 1 day to reveal.
    ///      Sends ETH to party B.
    function timeOut() public {
        require(block.timestamp > timeB + 1 days);
        require(address(this).balance >= 2 ether);
        partyB.transfer(2 ether);
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
    ///  @param _recipient The recipient.
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
        payable(msg.sender).transfer(ethToReceive);
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
    ///  @param _slots The amount of slots the coffer will have.
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
        payable(msg.sender).transfer(coffer.slots[_slot]);
        coffer.slots[_slot] = 0;
    }

    /// @dev Closes an account withdrawing all the money.
    function closeAccount() external {
        Coffer storage coffer = coffers[msg.sender];
        uint256 amountToSend;
        for (uint256 i = 0; i < coffer.nbSlots; ++i) {
            amountToSend += coffer.slots[i];
        }
        coffer.nbSlots = 0;
        payable(msg.sender).transfer(amountToSend);
    }
}

/* Exercise 9 */

/// @dev Contract for simple coffer to deposit to and withdraw from.
contract CommonCoffers {
    mapping(address => uint256) public coffers;
    uint256 public scalingFactor;

    /// @dev Deposits money in one's coffer.
    /// @param _owner The coffer to deposit money on.
    function deposit(address _owner) external payable {
        if (scalingFactor != 0) {
            uint256 toAdd = (scalingFactor * msg.value) / (address(this).balance - msg.value);
            coffers[_owner] += toAdd;
            scalingFactor += toAdd;
        } else {
            scalingFactor = 100;
            coffers[_owner] = 100;
        }
    }

    /// @dev Withdraws all of the money from one's coffer.
    /// @param _amount The amount to withdraw from one's coffer.
    function withdraw(uint256 _amount) external {
        uint256 toRemove = (scalingFactor * _amount) / address(this).balance;
        coffers[msg.sender] -= toRemove;
        scalingFactor -= toRemove;
        payable(msg.sender).transfer(_amount);
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
    address payable[2] public sides;

    uint256 public baseDeposit;
    uint256 public reward;
    Side public winner;
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
        sides[uint256(_side)] = payable(msg.sender);
        partyDeposits[uint256(_side)] = msg.value;
    }

    /// @dev Declares the winner as an owner.
    ///      Note that in case no one funded for the winner side when the owner makes its transaction, having someone else deposit to get the reward is fine and doesn't affect the mechanism.
    /// @param _winner The side that is eligible to a reward according to owner.
    function declareWinner(Side _winner) public {
        require(msg.sender == owner, "Only owner allowed");
        require(!declared, "Winner already declared");
        declared = true;
        winner = _winner;
    }

    /// @dev Pays the reward to the winner. Reimburses the surplus deposit for both parties if there was one.
    function payReward() public {
        require(declared, "The winner is not declared");
        uint256 depositA = partyDeposits[0];
        uint256 depositB = partyDeposits[1];

        partyDeposits[0] = 0;
        partyDeposits[1] = 0;

        // Pays the winner. Note that if no one put a deposit for the winning side, the reward will be burnt.
        require(sides[uint256(winner)].send(reward), "Unsuccessful send");

        // Reimburse the surplus deposit if there was one.
        if (depositA > baseDeposit && sides[0] != address(0)) {
            require(sides[0].send(depositA - baseDeposit), "Unsuccessful send");
        }

        if (depositB > baseDeposit && sides[1] != address(0)) {
            require(sides[1].send(depositB - baseDeposit), "Unsuccessful send");
        }

        reward = 0;
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
    ///  @param _name The first name of the user.
    ///  @param _surname The last name of the user.
    ///  @param _nonce An arbitrary number to allow multiple users with the same first and last name.
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
    ///  @param _number The number guessed.
    ///  @param _blindingFactor Bytes that has been used for the commitment to blind the guess.
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
        for (uint256 i = cursorDistribute; i < winners.length && (_count == 0 || i < cursorDistribute + _count); i++) {
            // Send ether to the winners, use send not to block.
            payable(winners[i]).send(totalBalance / (winners.length - numberOfLosers));
            if (i == winners.length - 1) currentStage = Stage.Distributed;
        }
        // Update the cursor in case we haven't finished going through the list.
        cursorDistribute += _count;
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
        payable(owner).transfer(address(this).balance);
    }
}

/* Exercise 15 */

/// @dev This is a game where an Owner considered as TRUSTED can set rounds with rewards.
///      The Owner allows several users to compete for the rewards. The fastest user gets all the rewards.
///      The users can propose new rounds but it's up to the Owner to fund them.
///      The Owner can clear the rounds to create fresh new ones.
contract WinnerTakesAll {
    struct Round {
        uint256 rewards;
        mapping(address => bool) isAllowed;
    }

    address public owner;
    Round[] public rounds;

    /* CONSTRUCTOR */

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /// @dev Creates new rounds.
    /// @param _numberOfRounds The number of rounds to create.
    function createNewRounds(uint256 _numberOfRounds) external {
        for (uint256 i = 0; i < _numberOfRounds; i++) {
            rounds.push();
        }
    }

    /// @dev Set the reward at a specific round.
    /// @param _roundIndex The index of the round concerned by the reward.
    function setRewardsAtRound(uint256 _roundIndex) external payable onlyOwner {
        require(rounds[_roundIndex].rewards == 0);
        rounds[_roundIndex].rewards = msg.value;
    }

    /// @dev Allows the participation of a set of addresses for a specific round.
    /// @param _roundIndex The index of the round concerned.
    /// @param _recipients The set of addresses allowed to participate.
    function setRewardsAtRoundFor(uint256 _roundIndex, address[] calldata _recipients) external onlyOwner {
        for (uint256 i; i < _recipients.length; i++) {
            rounds[_roundIndex].isAllowed[_recipients[i]] = true;
        }
    }

    /// @dev Checks if an address can participate in this round.
    /// @param _roundIndex The index of the round to be checked.
    /// @param _recipient The address whose authorization is to be checked.
    function isAllowedAt(uint256 _roundIndex, address _recipient) external view returns (bool) {
        return rounds[_roundIndex].isAllowed[_recipient];
    }

    /// @dev Withdraws rewards of a round.
    /// @param _roundIndex The index of the round concerned.
    function withdrawRewards(uint256 _roundIndex) external {
        require(rounds[_roundIndex].isAllowed[msg.sender]);
        uint256 amount = rounds[_roundIndex].rewards;
        rounds[_roundIndex].rewards = 0;
        payable(msg.sender).transfer(amount);
    }

    /// @dev Delete all the rounds created.
    function clearRounds() external onlyOwner {
        delete rounds;
    }

    /// @dev Withdraws all the ethers to owner's address.
    function withdrawETH() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
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
        (bool success,) = (block.timestamp < deadline ? onBehalf: ADMIN).call{value: REWARD_AMOUNT}("");
        require(success, "Transfer failed");
    }
}
