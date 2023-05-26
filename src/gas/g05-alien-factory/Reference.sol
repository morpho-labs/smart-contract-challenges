// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {IAlienFactory} from "./Common.sol";

contract AlienFactory is IAlienFactory {
    address internal _parent;
    uint256 internal _eyesNumber;
    uint256 internal _legsNumber;
    uint256 internal _armsNumber;
    uint256 internal _antennaNumber;
    bool internal _hasNose;
    uint256 internal _height;
    Color internal _color;
    uint256 internal _age;
    Planet internal _planet;

    function setAlienAttributes(
        address parent,
        uint256 eyesNumber,
        uint256 legsNumber,
        uint256 armsNumber,
        uint256 antennaNumber,
        bool hasNose,
        uint256 height,
        Color color,
        uint256 age,
        Planet planet
    ) external {
        require(eyesNumber <= 1000);
        require(legsNumber <= 1000);
        require(armsNumber <= 1000);
        require(antennaNumber <= 1000);
        require(height <= 1e10);
        require(age <= 2e4);

        _parent = parent;
        _eyesNumber = eyesNumber;
        _legsNumber = legsNumber;
        _armsNumber = armsNumber;
        _antennaNumber = antennaNumber;
        _hasNose = hasNose;
        _height = height;
        _color = color;
        _age = age;
        _planet = planet;
    }

    function getAlienAttributes()
        external
        view
        returns (
            address parent,
            uint256 eyesNumber,
            uint256 legsNumber,
            uint256 armsNumber,
            uint256 antennaNumber,
            bool hasNose,
            uint256 height,
            Color color,
            uint256 age,
            Planet planet
        )
    {
        parent = _parent;
        eyesNumber = _eyesNumber;
        legsNumber = _legsNumber;
        armsNumber = _armsNumber;
        antennaNumber = _antennaNumber;
        hasNose = _hasNose;
        height = _height;
        color = _color;
        age = _age;
        planet = _planet;
    }
}
