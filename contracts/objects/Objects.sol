//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.9;

import "./ArtifactStruct.sol";
import "./SnakeStruct.sol";
import "./EggStruct.sol";
import "./ArtifactStatsStruct.sol";
import "./SnakeStatsStruct.sol";
import "./EggStatsStruct.sol";
import "./SnakeAppliedArtifactsStruct.sol";


abstract contract Objects is
    ArtifactStruct,
    ArtifactStatsStruct,
    SnakeStruct,
    SnakeStatsStruct,
    EggStruct,
    EggStatsStruct,
    SnakeAppliedArtifactsStruct
{}