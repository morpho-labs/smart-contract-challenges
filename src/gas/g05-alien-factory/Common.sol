// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

interface IAlienFactory {
    enum Color {
        Red,
        Orange,
        Yellow,
        Green,
        Cyan,
        Blue,
        Violet,
        Pink
    }

    enum Planet {
        Mercury,
        Venus,
        Mars,
        Jupiter,
        Saturn,
        Uranus,
        Neptune,
        Pluto
    }

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
    ) external;

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
        );
}
