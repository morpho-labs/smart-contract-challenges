// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /// @dev Initializes the contract setting the deployer as the initial owner.
    constructor() {
        transferOwnership(msg.sender);
    }

    /// @dev Throws if called by any account other than the owner.
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /// @dev Returns the address of the current owner.
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /// @dev Throws if the sender is not the owner.
    function _checkOwner() internal view virtual {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
    }

    /// @dev Transfers ownership of the contract to a new account (`newOwner`).
    /// @dev Can only be called by the current owner.
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract TokenV2 is Ownable {
    uint256 totalSupply;
    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;

    event Transfer(address from, address to, uint256 amount);
    event Approval(address owner, address spender, uint256 amount);
    event Mint(address minter, uint256 amount);
    event Redeem(address redeemer, uint256 amount);

    function mint(uint256 amount) external returns (bool) {
        require(msg.sender == owner() || allowed[owner()][msg.sender] >= amount);
        balances[msg.sender] += amount;
        if (msg.sender != owner()) {
            allowed[owner()][msg.sender] -= amount;
        }
        emit Mint(msg.sender, amount);
        return true;
    }

    function redeem(uint256 amount) external returns (bool) {
        require(balances[msg.sender] >= amount);
        balances[msg.sender] -= amount;
        emit Redeem(msg.sender, amount);
        return true;
    }

    function transfer(address to, uint256 amount) external returns (bool success) {
        require(balances[msg.sender] >= amount);
        balances[msg.sender] -= amount;
        balances[to] += amount;
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function approve(address spender, uint256 tokens) external returns (bool success) {
        require(allowed[msg.sender][spender] == 0, "");
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }
}
