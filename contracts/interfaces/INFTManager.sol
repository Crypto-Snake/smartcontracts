//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "../objects/Objects.sol";

abstract contract INFTManager is Objects {
    function updateSnakeProperties(uint id, Snake memory properties) external virtual;
    function getSnakeProperties(uint id) external virtual view returns (Snake memory);
    function getSnakeStats(uint tokenId) external virtual view returns (SnakeStats memory);
    function updateEggProperties(uint id, Egg memory properties) external virtual;
    function getEggProperties(uint id) external virtual view returns (Egg memory);
    function updateEggStats(uint tokenId, EggStats memory stats) external virtual;
    function getEggStats(uint tokenId) external virtual view returns (EggStats memory);
    function updateArtifactProperties(uint id, Artifact memory properties) external virtual;
    function getArtifactProperties(uint id) external virtual view returns (Artifact memory);
    function isStakeAmountGraterThanRequired(uint snakeId) public virtual view returns (bool);
}