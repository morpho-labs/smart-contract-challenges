// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Test} from "forge-std/Test.sol";
import {console2} from "forge-std/console2.sol";

import {Utils} from "./Utils.sol";

import {ILoops} from "src/gas/g01-loops/Common.sol";
import {Loops as Reference} from "src/gas/g01-loops/Reference.sol";
import {Loops as Optimized} from "src/gas/g01-loops/Optimized.sol";

contract TestLoop is Test, Utils {
    ILoops ref;
    ILoops opti;

    function setUp() public {
        ref = new Reference();
        opti = new Optimized();
    }

    function testLoop1(bytes32 seed, uint256 length) public {
        uint256[] memory array = randomUint256DynamicSizeArray(seed, 0, type(uint128).max, _bound(length, 0, 5000));
        assertEq(ref.loop1(array), opti.loop1(array));
    }

    function testLoop2(bytes32 seed) public {
        uint256[10] memory array = randomUint256FixedSize10Array(seed, 0, type(uint128).max);
        assertEq(ref.loop2(array), opti.loop2(array));
    }

    function testGasLoop1() public view {
        uint256 refGas = 0;
        uint256 optiGas = 0;
        bytes memory data;

        data = abi.encodeWithSelector(
            ref.loop1.selector, randomUint256DynamicSizeArray(keccak256("testGasLoop1"), 0, type(uint128).max, 5)
        );
        refGas += staticCallGasUsage(address(ref), data);
        optiGas += staticCallGasUsage(address(opti), data);

        data = abi.encodeWithSelector(
            ref.loop1.selector, randomUint256DynamicSizeArray(keccak256("testGasLoop1"), 0, type(uint128).max, 50)
        );
        refGas += staticCallGasUsage(address(ref), data);
        optiGas += staticCallGasUsage(address(opti), data);

        data = abi.encodeWithSelector(
            ref.loop1.selector, randomUint256DynamicSizeArray(keccak256("testGasLoop1"), 0, type(uint128).max, 500)
        );
        refGas += staticCallGasUsage(address(ref), data);
        optiGas += staticCallGasUsage(address(opti), data);

        data = abi.encodeWithSelector(
            ref.loop1.selector, randomUint256DynamicSizeArray(keccak256("testGasLoop1"), 0, type(uint128).max, 5000)
        );
        refGas += staticCallGasUsage(address(ref), data);
        optiGas += staticCallGasUsage(address(opti), data);

        printGasResult(refGas, 988255, 988255, optiGas);
    }

    function testGasLoop2() public view {
        uint256 refGas = 0;
        uint256 optiGas = 0;
        bytes memory data;

        data = abi.encodeWithSelector(
            ref.loop2.selector, randomUint256FixedSize10Array(keccak256("testGasLoop2.1"), 0, type(uint128).max)
        );
        refGas += staticCallGasUsage(address(ref), data);
        optiGas += staticCallGasUsage(address(opti), data);

        data = abi.encodeWithSelector(
            ref.loop2.selector, randomUint256FixedSize10Array(keccak256("testGasLoop2.2"), 0, type(uint128).max)
        );
        refGas += staticCallGasUsage(address(ref), data);
        optiGas += staticCallGasUsage(address(opti), data);

        data = abi.encodeWithSelector(
            ref.loop2.selector, randomUint256FixedSize10Array(keccak256("testGasLoop2.3"), 0, type(uint128).max)
        );
        refGas += staticCallGasUsage(address(ref), data);
        optiGas += staticCallGasUsage(address(opti), data);

        printGasResult(refGas, 8932, 8932, optiGas);
    }

    function testGasLoop3() public view {
        uint256 refGas = 0;
        uint256 optiGas = 0;
        bytes memory data;

        data = abi.encodeWithSelector(
            ref.loop3.selector, randomUint256DynamicSizeArray(keccak256("testGasLoop3"), 0, type(uint128).max, 2)
        );
        refGas += staticCallGasUsage(address(ref), data);
        optiGas += staticCallGasUsage(address(opti), data);

        data = abi.encodeWithSelector(
            ref.loop3.selector, randomUint256DynamicSizeArray(keccak256("testGasLoop3"), 0, type(uint128).max, 7)
        );
        refGas += staticCallGasUsage(address(ref), data);
        optiGas += staticCallGasUsage(address(opti), data);

        data = abi.encodeWithSelector(
            ref.loop3.selector, randomUint256DynamicSizeArray(keccak256("testGasLoop3"), 0, type(uint128).max, 10)
        );
        refGas += staticCallGasUsage(address(ref), data);
        optiGas += staticCallGasUsage(address(opti), data);

        data = abi.encodeWithSelector(
            ref.loop3.selector, randomUint256DynamicSizeArray(keccak256("testGasLoop3"), 0, type(uint128).max, 15)
        );
        refGas += staticCallGasUsage(address(ref), data);
        optiGas += staticCallGasUsage(address(opti), data);

        printGasResult(refGas, 8467, 8467, optiGas);
    }
}
