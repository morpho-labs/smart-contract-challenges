// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {ILoops} from "./Common.sol";

contract Loops is ILoops {
    function loop1(uint256[] calldata array) external pure returns (uint256 result) {
        for (uint256 i = 0; i < array.length; i++) {
            result += array[i];
        }
    }

    function loop2(uint256[10] calldata array) external pure returns (uint256 result) {
        for (uint256 i = 0; i < array.length; i++) {
            result += array[i];
        }
    }

    function loop3(uint256[] calldata array) external pure returns (uint256 result) {
        require(array.length <= 10);
        for (uint256 i = 0; i < array.length; i++) {
            result += array[i];
        }
    }
}
