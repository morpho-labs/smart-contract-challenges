// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {GuessTheNumber2, ISolver2} from "./Common.sol";

contract Solver2 is ISolver2 {
    function solve(GuessTheNumber2 game) external returns (uint256) {
        uint256 min = 0;
        uint256 max = type(uint256).max;
        while (max - min >= 1) {
            uint256 middle = min + (max - min) / 2;
            try this.cheat(game, middle) {
                revert();
            } catch Error(string memory err) {
                GuessTheNumber2.Result result = abi.decode(bytes(err), (GuessTheNumber2.Result));
                if (result == GuessTheNumber2.Result.GREATER) {
                    min = middle + 1;
                } else if (result == GuessTheNumber2.Result.LESS) {
                    max = middle - 1;
                } else {
                    min = middle;
                    max = middle;
                }
            }
        }
        return min;
    }

    function cheat(GuessTheNumber2 game, uint256 guess) external {
        GuessTheNumber2.Result result = game.guess(guess);
        revert(string(abi.encode(result)));
    }
}
