// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {IMatrixMultiplication} from "./Common.sol";

contract MatrixMultiplication is IMatrixMultiplication {
    uint256[][] internal _matrixA;

    /// @dev Sets the matrix A.
    /// @notice Must NOT be optimized.
    /// @param matrixA The matrix A.
    function setMatrixA(uint256[][] calldata matrixA) external {
        uint256 m = matrixA.length;
        uint256 n = matrixA[0].length;

        _matrixA = new uint256[][](m);
        for (uint256 i = 0; i < m; i++) {
            _matrixA[i] = new uint256[](n);

            for (uint256 j = 0; j < n; j++) {
                _matrixA[i][j] = matrixA[i][j];
            }
        }
    }

    /// @dev Performs matrix multiplication of matrix A with matrix B and returns the resulting matrix.
    ///      The multiplication results are intentionally allowed to overflow.
    ///      Assumes that the dimensions of matrix A and matrix B are correct and compatible.
    /// @notice Must be optimized.
    /// @param matrixB The matrix B to be multiplied with matrix A.
    /// @return result The matrix resulting from the multiplication of matrix A with matrix B.
    function matrixMul(uint256[][] calldata matrixB) external view returns (uint256[][] memory result) {
        uint256 m = _matrixA.length;
        uint256 n = matrixB[0].length;

        result = new uint256[][](m);
        for (uint256 i = 0; i < m; i++) {
            result[i] = new uint256[](n);

            for (uint256 j = 0; j < n; j++) {
                result[i][j] += matrixMulElement(matrixB, i, j);
            }
        }
    }

    /// @dev Calculates a single element of the resulting matrix by multiplying the corresponding row of matrix A with the column of matrix B.
    ///      The multiplication results are intentionally allowed to overflow.
    ///      Assumes that the dimensions of matrix A and matrix B are correct and compatible.
    /// @notice Must be optimized.
    /// @param matrixB The matrix B to be multiplied with matrix A.
    /// @param i The row of the element to compute in the resulting matrix.
    /// @param j The column of the element to compute in the resulting matrix.
    /// @return result The calculated element of the resulting matrix.
    function matrixMulElement(uint256[][] calldata matrixB, uint256 i, uint256 j)
        public
        view
        returns (uint256 result)
    {
        uint256 size = matrixB.length;
        for (uint256 k = 0; k < size; k++) {
            unchecked {
                result += _matrixA[i][k] * matrixB[k][j];
            }
        }
    }
}
