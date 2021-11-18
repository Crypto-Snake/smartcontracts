//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

abstract contract ArtifactStruct {
    struct Artifact {
        string Name;
        string Description;
        string URI;
        uint Price;
    }
}