// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

contract GuessTheNumber {
    uint256 private _number;
    bool public guessed;

    enum Result {
        LESS,
        GREATER,
        EQUAL
    }

    constructor(uint256 number) {
        _number = number;
    }

    function guess(uint256 guessedNumber) external returns (Result) {
        require(!guessed);
        guessed = true;
        if (_number < guessedNumber) return Result.LESS;
        else if (_number > guessedNumber) return Result.GREATER;
        else return Result.EQUAL;
    }
}

interface ISolver {
    function solve(GuessTheNumber) external returns (uint256);
}
