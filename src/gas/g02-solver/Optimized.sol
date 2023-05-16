// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {GuessTheNumber, ISolver} from "./Common.sol";

contract Solver is ISolver {
    function solve(GuessTheNumber game) external returns (uint256) {
        uint256 min = 0;
        uint256 max = type(uint256).max;
        while (max - min >= 1) {
            uint256 middle = min + (max - min) / 2;
            try this.cheat(game, middle) {
                revert();
            } catch Error(string memory err) {
                GuessTheNumber.Result result = abi.decode(bytes(err), (GuessTheNumber.Result));
                if (result == GuessTheNumber.Result.GREATER) {
                    min = middle + 1;
                } else if (result == GuessTheNumber.Result.LESS) {
                    max = middle - 1;
                } else {
                    min = middle;
                    max = middle;
                }
            }
        }
        return min;
    }

    function cheat(GuessTheNumber game, uint256 _guess) external {
        GuessTheNumber.Result result = game.guess(_guess);
        revert(string(abi.encode(result)));
    }
}
