// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

contract TokenIndicators {
    uint256 public price;
    uint256 public volume;
    uint256 public volatility;
    uint256 public marketCap;
    uint256 public holders;
    uint256 public totalTransfers;
    uint256 public age;

    constructor(
        uint256 _price,
        uint256 _volume,
        uint256 _volatility,
        uint256 _marketCap,
        uint256 _holders,
        uint256 _totalTransfers,
        uint256 _age
    ) {
        price = _price;
        volume = _volume;
        volatility = _volatility;
        marketCap = _marketCap;
        holders = _holders;
        totalTransfers = _totalTransfers;
        age = _age;
    }
}

contract GlobalCoefficientsProvider {
    uint256 public gcPrice;
    uint256 public gcVolume;
    uint256 public gcVolatility;
    uint256 public gcMarketCap;
    uint256 public gcHolders;
    uint256 public gcTotalTransfers;
    uint256 public gcAge;

    constructor(
        uint256 _gcPrice,
        uint256 _gcVolume,
        uint256 _gcVolatility,
        uint256 _gcMarketCap,
        uint256 _gcHolders,
        uint256 _gcTotalTransfers,
        uint256 _gcAge
    ) {
        gcPrice = _gcPrice;
        gcVolume = _gcVolume;
        gcVolatility = _gcVolatility;
        gcMarketCap = _gcMarketCap;
        gcHolders = _gcHolders;
        gcTotalTransfers = _gcTotalTransfers;
        gcAge = _gcAge;
    }
}

interface ITokenHeuristic {
    function setPersonalCoefficients(
        uint256 pcPrice,
        uint256 pcVolume,
        uint256 pcVolatility,
        uint256 pcMarketCap,
        uint256 pcHolders,
        uint256 pcTotalTransfers,
        uint256 pcAge
    ) external;
    function setGlobalCoefficientsProvider(GlobalCoefficientsProvider) external;
    function score(TokenIndicators, TokenIndicators) external view returns (uint256);
}
