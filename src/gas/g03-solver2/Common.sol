// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

contract GuessTheNumber2 {
    uint256 private immutable number;
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

interface ISolver2 {
    function solve(GuessTheNumber2) external returns (uint256);
}
