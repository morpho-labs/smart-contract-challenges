// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

interface ILoops {
    function loop1(uint256[] calldata array) external pure returns (uint256);
    function loop2(uint256[10] calldata array) external pure returns (uint256);
    function loop3(uint256[] calldata array) external pure returns (uint256);
}
