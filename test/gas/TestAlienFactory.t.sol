// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Test} from "forge-std/Test.sol";

import {Utils} from "./Utils.sol";

import {IAlienFactory} from "src/gas/g02-alien-factory/Common.sol";
import {AlienFactory as Reference} from "src/gas/g02-alien-factory/Reference.sol";
import {AlienFactory as Optimized} from "src/gas/g02-alien-factory/Optimized.sol";

contract TestAlienFactory is Test, Utils {
    IAlienFactory ref;
    IAlienFactory opti;

    struct AlienAttributes {
        address parent;
        uint256 eyesNumber;
        uint256 legsNumber;
        uint256 armsNumber;
        uint256 antennaNumber;
        bool hasNose;
        uint256 height;
        uint8 color;
        uint256 age;
        uint8 planet;
    }

    function setUp() public {
        ref = new Reference();
        opti = new Optimized();
    }

    function testAlienFactory(AlienAttributes memory alienAttr) public {
        _boundAlienAttributes(alienAttr);

        (bool success,) =
            address(opti).call(abi.encodeWithSelector(IAlienFactory.setAlienAttributes.selector, alienAttr));
        require(success);

        bytes memory data;
        (success, data) = address(opti).staticcall(abi.encodeWithSelector(IAlienFactory.getAlienAttributes.selector));
        require(success);
        AlienAttributes memory retrievedAlienAttr = abi.decode(data, (AlienAttributes));

        assertEq(alienAttr.parent, retrievedAlienAttr.parent, "parent");
        assertEq(alienAttr.eyesNumber, retrievedAlienAttr.eyesNumber, "eyesNumber");
        assertEq(alienAttr.legsNumber, retrievedAlienAttr.legsNumber, "legsNumber");
        assertEq(alienAttr.armsNumber, retrievedAlienAttr.armsNumber, "armsNumber");
        assertEq(alienAttr.antennaNumber, retrievedAlienAttr.antennaNumber, "antennaNumber");
        assertEq(alienAttr.hasNose, retrievedAlienAttr.hasNose, "hasNose");
        assertEq(alienAttr.height, retrievedAlienAttr.height, "height");
        assertEq(alienAttr.color, retrievedAlienAttr.color, "color");
        assertEq(alienAttr.age, retrievedAlienAttr.age, "age");
        assertEq(alienAttr.planet, retrievedAlienAttr.planet, "planet");
    }

    function testAlienFactoryReverts(AlienAttributes memory alienAttr, uint256 value) public {
        _boundAlienAttributes(alienAttr);
        alienAttr.eyesNumber = _bound(value, 1001, type(uint256).max);
        (bool success,) =
            address(opti).call(abi.encodeWithSelector(IAlienFactory.setAlienAttributes.selector, alienAttr));
        require(!success, "eyesNumber");

        _boundAlienAttributes(alienAttr);
        alienAttr.legsNumber = _bound(value, 1001, type(uint256).max);
        (success,) = address(opti).call(abi.encodeWithSelector(IAlienFactory.setAlienAttributes.selector, alienAttr));
        require(!success, "legsNumber");

        _boundAlienAttributes(alienAttr);
        alienAttr.armsNumber = _bound(value, 1001, type(uint256).max);
        (success,) = address(opti).call(abi.encodeWithSelector(IAlienFactory.setAlienAttributes.selector, alienAttr));
        require(!success, "armsNumber");

        _boundAlienAttributes(alienAttr);
        alienAttr.antennaNumber = _bound(value, 1001, type(uint256).max);
        (success,) = address(opti).call(abi.encodeWithSelector(IAlienFactory.setAlienAttributes.selector, alienAttr));
        require(!success, "antennaNumber");

        _boundAlienAttributes(alienAttr);
        alienAttr.height = _bound(value, 1e10 + 1, type(uint256).max);
        (success,) = address(opti).call(abi.encodeWithSelector(IAlienFactory.setAlienAttributes.selector, alienAttr));
        require(!success, "height");

        _boundAlienAttributes(alienAttr);
        alienAttr.age = _bound(value, 2e4 + 1, type(uint256).max);
        (success,) = address(opti).call(abi.encodeWithSelector(IAlienFactory.setAlienAttributes.selector, alienAttr));
        require(!success, "age");
    }

    function testGasAlienFactory() public {
        uint256 refGas = 0;
        uint256 optiGas = 0;
        bytes memory data;

        data = abi.encodeWithSelector(
            IAlienFactory.setAlienAttributes.selector, _randomAlienAttributes(keccak256("testGasAlienFactory.1"))
        );
        refGas += callGasUsage(address(ref), 0, data);
        optiGas += callGasUsage(address(opti), 0, data);

        data = abi.encodeWithSelector(IAlienFactory.getAlienAttributes.selector);
        refGas += staticcallGasUsage(address(ref), data);
        optiGas += staticcallGasUsage(address(opti), data);

        data = abi.encodeWithSelector(
            IAlienFactory.setAlienAttributes.selector, _randomAlienAttributes(keccak256("testGasAlienFactory.2"))
        );
        refGas += callGasUsage(address(ref), 0, data);
        optiGas += callGasUsage(address(opti), 0, data);

        data = abi.encodeWithSelector(IAlienFactory.getAlienAttributes.selector);
        refGas += staticcallGasUsage(address(ref), data);
        optiGas += staticcallGasUsage(address(opti), data);

        printGasResult(refGas, 55555, 29166, optiGas);
    }

    function _randomAlienAttributes(bytes32 seed) internal pure returns (AlienAttributes memory alienAttr) {
        alienAttr = AlienAttributes({
            parent: address(bytes20(seed = keccak256(abi.encode(seed)))),
            eyesNumber: uint256(seed = keccak256(abi.encode(seed))),
            legsNumber: uint256(seed = keccak256(abi.encode(seed))),
            armsNumber: uint256(seed = keccak256(abi.encode(seed))),
            antennaNumber: uint256(seed = keccak256(abi.encode(seed))),
            hasNose: uint256(seed = keccak256(abi.encode(seed))) % 2 == 0,
            height: uint256(seed = keccak256(abi.encode(seed))),
            color: uint8(uint256(seed = keccak256(abi.encode(seed)))),
            age: uint256(seed = keccak256(abi.encode(seed))),
            planet: uint8(uint256(seed = keccak256(abi.encode(seed))))
        });
        _boundAlienAttributes(alienAttr);
    }

    function _boundAlienAttributes(AlienAttributes memory alienAttr) internal pure {
        alienAttr.eyesNumber = _bound(alienAttr.eyesNumber, 0, 1000);
        alienAttr.legsNumber = _bound(alienAttr.legsNumber, 0, 1000);
        alienAttr.armsNumber = _bound(alienAttr.armsNumber, 0, 1000);
        alienAttr.antennaNumber = _bound(alienAttr.antennaNumber, 0, 1000);
        alienAttr.height = _bound(alienAttr.height, 0, 1e10);
        alienAttr.color = uint8(_bound(alienAttr.age, 0, 7));
        alienAttr.age = _bound(alienAttr.age, 0, 1e4);
        alienAttr.planet = uint8(_bound(alienAttr.age, 0, 7));
    }
}
