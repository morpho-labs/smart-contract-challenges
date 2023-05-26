// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {TokenIndicators, GlobalCoefficientsProvider, ITokenHeuristic} from "./Common.sol";

contract TokenHeuristic is ITokenHeuristic {
    uint256 internal _pcPrice;
    uint256 internal _pcVolume;
    uint256 internal _pcVolatility;
    uint256 internal _pcMarketCap;
    uint256 internal _pcHolders;
    uint256 internal _pcTotalTransfers;
    uint256 internal _pcAge;

    GlobalCoefficientsProvider internal _globalCoefficientsProvider;

    function setPersonalCoefficients(
        uint256 pcPrice,
        uint256 pcVolume,
        uint256 pcVolatility,
        uint256 pcMarketCap,
        uint256 pcHolders,
        uint256 pcTotalTransfers,
        uint256 pcAge
    ) external {
        _pcPrice = pcPrice;
        _pcVolume = pcVolume;
        _pcVolatility = pcVolatility;
        _pcMarketCap = pcMarketCap;
        _pcHolders = pcHolders;
        _pcTotalTransfers = pcTotalTransfers;
        _pcAge = pcAge;
    }

    function setGlobalCoefficientsProvider(GlobalCoefficientsProvider globalCoefficientsProvider) external {
        _globalCoefficientsProvider = globalCoefficientsProvider;
    }

    function score(TokenIndicators tokenA, TokenIndicators tokenB) external view returns (uint256) {
        return (_score(tokenA) + _score(tokenB)) * 1000
            / (_score(tokenA) > _score(tokenB) ? _score(tokenA) - _score(tokenB) : _score(tokenB) - _score(tokenA));
    }

    function _score(TokenIndicators token) internal view returns (uint256 s) {
        s += (_pcPrice + _globalCoefficientsProvider.gcPrice()) * token.price();
        s += (_pcVolume + _globalCoefficientsProvider.gcVolume()) * token.volume();
        s += (_pcVolatility + _globalCoefficientsProvider.gcVolatility()) * token.volatility();
        s += (_pcMarketCap + _globalCoefficientsProvider.gcMarketCap()) * token.marketCap();
        s += (_pcHolders + _globalCoefficientsProvider.gcHolders()) * token.holders();
        s += (_pcTotalTransfers + _globalCoefficientsProvider.gcTotalTransfers()) * token.totalTransfers();
        s += (_pcAge + _globalCoefficientsProvider.gcAge()) * token.age();
    }
}
