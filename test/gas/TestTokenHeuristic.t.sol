// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Test} from "forge-std/Test.sol";

import {Utils} from "./Utils.sol";

import {TokenIndicators, GlobalCoefficientsProvider, ITokenHeuristic} from "src/gas-optis/g03-token-heuristic/Common.sol";
import {TokenHeuristic as Reference} from "src/gas-optis/g03-token-heuristic/Reference.sol";
import {TokenHeuristic as Optimized} from "src/gas-optis/g03-token-heuristic/Optimized.sol";

contract TestTokenHeuristic is Test, Utils {
    struct Coefficients {
        uint224 cPrice;
        uint224 cVolume;
        uint224 cVolatility;
        uint224 cMarketCap;
        uint224 cHolders;
        uint224 cTotalTransfers;
        uint224 cAge;
    }

    struct Token {
        uint16 price;
        uint16 volume;
        uint16 volatility;
        uint16 marketCap;
        uint16 holders;
        uint16 totalTransfers;
        uint16 age;
    }

    ITokenHeuristic ref;
    ITokenHeuristic opti;

    function setUp() public {
        ref = new Reference();
        opti = new Optimized();
    }

    function testTokenHeuristic(
        Coefficients memory gCoefs,
        Coefficients memory pCoefs,
        Token memory tokenA,
        Token memory tokenB
    ) public {
        GlobalCoefficientsProvider globalCoefficientsProvider = _createGlobalCoefficientsProvider(gCoefs);
        ref.setGlobalCoefficientsProvider(globalCoefficientsProvider);
        opti.setGlobalCoefficientsProvider(globalCoefficientsProvider);

        _setPersonalCoefficients(ref, pCoefs);
        _setPersonalCoefficients(opti, pCoefs);

        TokenIndicators tA = _createTokenIndicators(tokenA);
        TokenIndicators tB = _createTokenIndicators(tokenB);

        uint256 refRes = ref.score(tA, tB);
        uint256 optiRes = opti.score(tA, tB);

        assertEq(refRes, optiRes);
    }

    function testGasTokenHeuristic() public {
        uint256 refGas = 0;
        uint256 optiGas = 0;
        bytes memory data;

        GlobalCoefficientsProvider globalCoefficientsProvider =
            _createGlobalCoefficientsProvider(_randomCoefs(keccak256("testGasTokenHeuristic.1")));
        Coefficients memory pCoefs = _randomCoefs(keccak256("testGasTokenHeuristic.2"));
        TokenIndicators tokenA = _createTokenIndicators(_randomToken(keccak256("testGasTokenHeuristic.3")));
        TokenIndicators tokenB = _createTokenIndicators(_randomToken(keccak256("testGasTokenHeuristic.4")));

        ref.setGlobalCoefficientsProvider(globalCoefficientsProvider);
        opti.setGlobalCoefficientsProvider(globalCoefficientsProvider);

        _setPersonalCoefficients(ref, pCoefs);
        _setPersonalCoefficients(opti, pCoefs);

        data = abi.encodeWithSelector(ref.score.selector, tokenA, tokenB);
        refGas += staticcallGasUsage(address(ref), data);
        optiGas += staticcallGasUsage(address(opti), data);

        printGasResult(refGas, 22000, 19664, optiGas);
    }

    function _randomToken(bytes32 seed) internal pure returns (Token memory token) {
        return Token({
            price: uint16(_bound(uint256(seed = keccak256(abi.encode(seed))), 0, type(uint16).max)),
            volume: uint16(_bound(uint256(seed = keccak256(abi.encode(seed))), 0, type(uint16).max)),
            volatility: uint16(_bound(uint256(seed = keccak256(abi.encode(seed))), 0, type(uint16).max)),
            marketCap: uint16(_bound(uint256(seed = keccak256(abi.encode(seed))), 0, type(uint16).max)),
            holders: uint16(_bound(uint256(seed = keccak256(abi.encode(seed))), 0, type(uint16).max)),
            totalTransfers: uint16(_bound(uint256(seed = keccak256(abi.encode(seed))), 0, type(uint16).max)),
            age: uint16(_bound(uint256(seed = keccak256(abi.encode(seed))), 0, type(uint16).max))
        });
    }

    function _randomCoefs(bytes32 seed) internal pure returns (Coefficients memory coefs) {
        return Coefficients({
            cPrice: uint224(_bound(uint256(seed = keccak256(abi.encode(seed))), 0, type(uint224).max)),
            cVolume: uint224(_bound(uint256(seed = keccak256(abi.encode(seed))), 0, type(uint224).max)),
            cVolatility: uint224(_bound(uint256(seed = keccak256(abi.encode(seed))), 0, type(uint224).max)),
            cMarketCap: uint224(_bound(uint256(seed = keccak256(abi.encode(seed))), 0, type(uint224).max)),
            cHolders: uint224(_bound(uint256(seed = keccak256(abi.encode(seed))), 0, type(uint224).max)),
            cTotalTransfers: uint224(_bound(uint256(seed = keccak256(abi.encode(seed))), 0, type(uint224).max)),
            cAge: uint224(_bound(uint256(seed = keccak256(abi.encode(seed))), 0, type(uint224).max))
        });
    }

    function _createGlobalCoefficientsProvider(Coefficients memory coefs)
        internal
        returns (GlobalCoefficientsProvider)
    {
        return new GlobalCoefficientsProvider(
            coefs.cPrice,
            coefs.cVolume,
            coefs.cVolatility,
            coefs.cMarketCap,
            coefs.cHolders,
            coefs.cTotalTransfers,
            coefs.cAge
        );
    }

    function _createTokenIndicators(Token memory token) internal returns (TokenIndicators) {
        return new TokenIndicators(
            token.price, token.volume, token.volatility, token.marketCap, token.holders, token.totalTransfers, token.age
        );
    }

    function _setPersonalCoefficients(ITokenHeuristic tokenHeuristic, Coefficients memory coefs) internal {
        tokenHeuristic.setPersonalCoefficients(
            coefs.cPrice,
            coefs.cVolume,
            coefs.cVolatility,
            coefs.cMarketCap,
            coefs.cHolders,
            coefs.cTotalTransfers,
            coefs.cAge
        );
    }
}
