// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

interface IMatrixMultiplication {
    function setMatrixA(uint256[][] calldata matrixA) external;
    function matrixMul(uint256[][] calldata matrixB) external view returns (uint256[][] memory result);
    function matrixMulElement(uint256[][] calldata matrixB, uint256 i, uint256 j)
        external
        view
        returns (uint256 result);
}
