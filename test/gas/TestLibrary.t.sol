// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Test} from "forge-std/Test.sol";

import {Utils} from "./Utils.sol";

import {ISearchEngine, Library} from "src/gas/g04-library/Common.sol";
import {SearchEngine as Reference} from "src/gas/g04-library/Reference.sol";
import {SearchEngine as Optimized} from "src/gas/g04-library/Optimized.sol";

contract TestLibrary is Test, Utils {
    ISearchEngine ref;
    ISearchEngine opti;

    function setUp() public {
        ref = new Reference();
        opti = new Optimized();
    }

    function testSearchEngine(
        bytes32 salt,
        bytes32[10] calldata authors,
        bytes32[10] calldata names,
        bytes32[10] calldata contents
    ) public {
        Library lib = new Library{salt: salt}();
        for (uint256 i; i < 10; i++) {
            lib.newBook(authors[i], names[i], contents[i]);
        }
        for (uint256 i; i < 10; i++) {
            assertEq(contents[i], opti.search(lib, authors[i], names[i]));
        }
    }

    function testGasSearchEngine() public {
        uint256 refGas = 0;
        uint256 optiGas = 0;
        Library lib;
        bytes memory data;

        (lib, data) = _createLibraryAndData(
            keccak256("testGasSearchEngine.1"),
            keccak256("testGasSearchEngine.2"),
            keccak256("testGasSearchEngine.3"),
            keccak256("testGasSearchEngine.4")
        );
        refGas += staticcallGasUsage(address(ref), data);
        optiGas += staticcallGasUsage(address(opti), data);

        (lib, data) = _createLibraryAndData(
            keccak256("testGasSearchEngine.5"),
            keccak256("testGasSearchEngine.6"),
            keccak256("testGasSearchEngine.7"),
            keccak256("testGasSearchEngine.8")
        );
        refGas += staticcallGasUsage(address(ref), data);
        optiGas += staticcallGasUsage(address(opti), data);

        printGasResult(refGas, 7700, 7686, optiGas);
    }

    function _createLibraryAndData(bytes32 salt, bytes32 author, bytes32 name, bytes32 content)
        internal
        returns (Library lib, bytes memory data)
    {
        lib = new Library{salt: salt}();
        lib.newBook(author, name, content);
        data = abi.encodeWithSelector(ref.search.selector, lib, author, name);
    }
}
