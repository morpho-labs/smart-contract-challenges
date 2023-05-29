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
        uint256 newPrice,
        uint256 newVolume,
        uint256 newVolatility,
        uint256 newMarketCap,
        uint256 newHolders,
        uint256 newTotalTransfers,
        uint256 newAge
    ) {
        price = newPrice;
        volume = newVolume;
        volatility = newVolatility;
        marketCap = newMarketCap;
        holders = newHolders;
        totalTransfers = newTotalTransfers;
        age = newAge;
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
        uint256 newGcPrice,
        uint256 newGcVolume,
        uint256 newGcVolatility,
        uint256 newGcMarketCap,
        uint256 newGcHolders,
        uint256 newGcTotalTransfers,
        uint256 newGcAge
    ) {
        gcPrice = newGcPrice;
        gcVolume = newGcVolume;
        gcVolatility = newGcVolatility;
        gcMarketCap = newGcMarketCap;
        gcHolders = newGcHolders;
        gcTotalTransfers = newGcTotalTransfers;
        gcAge = newGcAge;
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
