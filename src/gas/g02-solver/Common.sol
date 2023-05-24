// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

contract GuessTheNumber {
    uint256 private number;
    bool public guessed;

    enum Result {
        LESS,
        GREATER,
        EQUAL
    }

    constructor(uint256 _number) {
        number = _number;
    }

    function guess(uint256 _guess) external returns (Result) {
        require(!guessed);
        guessed = true;
        if (number < _guess) return Result.LESS;
        else if (number > _guess) return Result.GREATER;
        else return Result.EQUAL;
    }
}

interface ISolver {
    function solve(GuessTheNumber) external returns (uint256);
}