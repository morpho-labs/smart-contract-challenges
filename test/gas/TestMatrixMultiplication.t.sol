// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Test} from "forge-std/Test.sol";

import {Utils} from "./Utils.sol";

import {IMatrixMultiplication} from "src/gas-optis/g07-matrix-multiplication/Common.sol";
import {MatrixMultiplication as Reference} from "src/gas-optis/g07-matrix-multiplication/Reference.sol";
import {MatrixMultiplication as Optimized} from "src/gas-optis/g07-matrix-multiplication/Optimized.sol";

contract TestMatrixMultiplication is Test, Utils {
    IMatrixMultiplication ref;
    IMatrixMultiplication opti;

    function setUp() public {
        ref = new Reference();
        opti = new Optimized();
    }

    function testMatrixMultiplication(bytes32 seed) public {
        (uint256[][] memory matrixA, uint256[][] memory matrixB, uint256 m, uint256 n) = _randomMatrixes(seed);
        ref.setMatrixA(matrixA);
        opti.setMatrixA(matrixA);
        uint256[][] memory refResult = ref.matrixMul(matrixB);
        uint256[][] memory optiResult = opti.matrixMul(matrixB);
        assertEq(refResult.length, optiResult.length, "invalid dimensions");
        assertEq(refResult[0].length, optiResult[0].length, "invalid dimensions");
        for (uint256 i = 0; i < m; i++) {
            for (uint256 j = 0; j < n; j++) {
                assertEq(refResult[i][j], optiResult[i][j]);
            }
        }
    }

    function testMatrixMultiplicationElement(bytes32 seed) public {
        (uint256[][] memory matrixA, uint256[][] memory matrixB, uint256 m, uint256 n) = _randomMatrixes(seed);
        ref.setMatrixA(matrixA);
        opti.setMatrixA(matrixA);
        for (uint256 i = 0; i < m; i++) {
            for (uint256 j = 0; j < n; j++) {
                uint256 refResult = ref.matrixMulElement(matrixB, i, j);
                uint256 optiResult = opti.matrixMulElement(matrixB, i, j);
                assertEq(refResult, optiResult);
            }
        }
    }

    function testGasMatrixMultiplication() public {
        uint256 refGas = 0;
        uint256 optiGas = 0;
        (uint256[][] memory matrixA, uint256[][] memory matrixB,,) =
            _randomMatrixes(keccak256("testGasMatrixMultiplication"));
        bytes memory data;

        ref.setMatrixA(matrixA);
        opti.setMatrixA(matrixA);

        data = abi.encodeWithSelector(ref.matrixMul.selector, matrixB);
        refGas += staticcallGasUsage(address(ref), data);
        optiGas += staticcallGasUsage(address(opti), data);

        data = abi.encodeWithSelector(ref.matrixMulElement.selector, matrixB);
        refGas += staticcallGasUsage(address(ref), data);
        optiGas += staticcallGasUsage(address(opti), data);

        printGasResult(refGas, 325000, 317655, optiGas);
    }

    function _randomMatrix(bytes32 seed, uint256 m, uint256 n)
        internal
        pure
        returns (uint256[][] memory result, bytes32 newSeed)
    {
        result = new uint256[][](m);
        for (uint256 i = 0; i < m; i++) {
            result[i] = new uint256[](n);
            for (uint256 j = 0; j < n; j++) {
                result[i][j] = uint256(seed = keccak256(abi.encode(seed)));
            }
        }
        newSeed = seed;
    }

    function _randomMatrixes(bytes32 seed)
        internal
        pure
        returns (uint256[][] memory matrixA, uint256[][] memory matrixB, uint256 m, uint256 n)
    {
        m = _bound(uint256(seed = keccak256(abi.encode(seed))), 1, 30);
        n = _bound(uint256(seed = keccak256(abi.encode(seed))), 1, 15);
        uint256 l = _bound(uint256(seed = keccak256(abi.encode(seed))), 1, 30);
        (matrixA, seed) = _randomMatrix(seed, m, l);
        (matrixB, seed) = _randomMatrix(seed, l, n);
    }
}
