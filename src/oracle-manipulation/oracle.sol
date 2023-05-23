// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC20} from "@solmate/tokens/ERC20.sol";

contract ERC20Real is ERC20 {
    constructor(string memory _name, string memory _symbol) ERC20(_name, _symbol, 18) {
        _mint(msg.sender, 1e6);
    }
}

contract LinearPool {
    uint256 public MAX_WANTED = 2 * 10e4;
    ERC20 public token;

    event Received(address, uint256);

    constructor() payable {
        token = new ERC20Real("Linear Token", "TOK");
        require(msg.value == 1e4);
        token.transferFrom(msg.sender, address(this), 1e4);
    }

    function buy() public payable returns (uint256) {
        require(msg.value > 0, "Deposit must be non-zero.");
        token.transfer(msg.sender, msg.value);
        return msg.value;
    }

    function sell(uint256 _amount) public returns (uint256) {
        token.transfer(address(this), _amount);
        (bool success,) = payable(msg.sender).call{value: _amount}("");
        require(success);
        return _amount;
    }

    function getOracle() public view returns (uint256) {
        return address(this).balance / token.totalSupply();
    }
}

contract LendingETH {
    mapping(address => uint256) private deposit;
    mapping(address => uint256) private borrow;
    LinearPool pool;

    constructor() payable {
        pool = new LinearPool();
        require(msg.value == 10e4 ether);
    }

    function depositToken(uint256 amount) external {
        pool.token().approve(address(this), amount);
        pool.token().transferFrom(msg.sender, address(this), amount);
        deposit[msg.sender] += amount;
    }

    function withdrawToken(uint256 amount) external {
        uint256 price = pool.getOracle();
        require(deposit[msg.sender] - borrow[msg.sender] / price >= amount);
        pool.token().transfer(msg.sender, amount);
        deposit[msg.sender] -= amount;
    }

    function lendETH(uint256 amount) external returns (uint256) {
        uint256 price = pool.getOracle();
        uint256 borrowPower = price * deposit[msg.sender] - borrow[msg.sender];
        if (borrowPower > 0) {
            return 0;
        } else {
            uint256 borrowed = min(borrowPower, amount);
            borrow[msg.sender] += borrowed;
            return borrowed;
        }
    }

    function repayETH(uint256 amount) external payable returns (uint256) {
        require(msg.value >= amount);
        uint256 realAmount = min(borrow[msg.sender], amount);
        borrow[msg.sender] -= realAmount;
        payable(msg.sender).transfer(amount - realAmount);
        return amount;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? b : a;
    }
}
