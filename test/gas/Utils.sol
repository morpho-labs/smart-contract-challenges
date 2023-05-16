// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {StdUtils} from "forge-std/StdUtils.sol";
import {console2} from "forge-std/console2.sol";

abstract contract Utils is StdUtils {
    function randomUint256DynamicSizeArray(bytes32 seed, uint256 min, uint256 max, uint256 length)
        internal
        pure
        returns (uint256[] memory res)
    {
        res = new uint256[](length);
        for (uint256 i = 0; i < length; i++) {
            seed = keccak256(abi.encode(seed, min, max, length));
            res[i] = _bound(uint256(seed), min, max);
        }
    }

    function randomUint256FixedSize10Array(bytes32 seed, uint256 min, uint256 max)
        internal
        pure
        returns (uint256[10] memory res)
    {
        for (uint256 i = 0; i < 10; i++) {
            seed = keccak256(abi.encode(seed, min, max));
            res[i] = _bound(uint256(seed), min, max);
        }
    }

    function printGasResult(uint256 ref, uint256 target, uint256 record, uint256 opti) internal view returns (bool) {
        if (opti > ref) {
            console2.log(unicode"Current:   %d ⛔", opti);
        }
        console2.log(unicode"Reference: %d", ref);
        if (target < opti && opti <= ref) {
            console2.log(unicode"Current:   %d ❌", opti);
        }
        console2.log(unicode"Target:    %d", target);
        if (record < opti && opti <= target) {
            console2.log(unicode"Current:   %d ✅", opti);
        }
        console2.log(unicode"Record:    %d", record);
        if (opti <= record) {
            console2.log(unicode"Current:   %d ⭐", opti);
        }
        return opti <= target;
    }

    function callGasUsage(address addr, uint256 value, bytes memory data) internal returns (uint256 res) {
        assembly {
            let g := gas()
            pop(call(gas(), addr, value, add(data, 0x20), mload(data), 0, 0))
            res := sub(g, gas())
        }
    }

    function staticCallGasUsage(address addr, bytes memory data) internal view returns (uint256 res) {
        assembly {
            let g := gas()
            pop(staticcall(gas(), addr, add(data, 0x20), mload(data), 0, 0))
            res := sub(g, gas())
        }
    }
}
