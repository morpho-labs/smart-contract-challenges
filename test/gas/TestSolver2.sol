// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Test} from "forge-std/Test.sol";

import {Utils} from "./Utils.sol";

import {GuessTheNumber2, ISolver2} from "src/gas/g03-solver2/Common.sol";
import {Solver2 as Reference} from "src/gas/g03-solver2/Reference.sol";
import {Solver2 as Optimized} from "src/gas/g03-solver2/Optimized.sol";

contract TestSolver is Test, Utils {
    ISolver2 ref;
    ISolver2 opti;

    function setUp() public {
        ref = new Reference();
        opti = new Optimized();
    }

    function testSolver2(uint256 solution) public {
        GuessTheNumber2 game = new GuessTheNumber2(solution);
        assertEq(opti.solve(game), solution);
    }

    function testGasSolver2() public {
        uint256 refGas = 0;
        uint256 optiGas = 0;
        bytes memory data;

        data = abi.encodeWithSelector(ref.solve.selector, new GuessTheNumber2(uint256(keccak256("testGasSolver.1"))));
        refGas += callGasUsage(address(ref), 0, data);
        optiGas += callGasUsage(address(opti), 0, data);

        data = abi.encodeWithSelector(ref.solve.selector, new GuessTheNumber2(uint256(keccak256("testGasSolver.2"))));
        refGas += callGasUsage(address(ref), 0, data);
        optiGas += callGasUsage(address(opti), 0, data);

        data = abi.encodeWithSelector(ref.solve.selector, new GuessTheNumber2(uint256(keccak256("testGasSolver.3"))));
        refGas += callGasUsage(address(ref), 0, data);
        optiGas += callGasUsage(address(opti), 0, data);

        printGasResult(refGas, 4162, 4162, optiGas);
    }
}
