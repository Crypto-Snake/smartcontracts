//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

abstract contract SnakeStruct {
    struct Snake {
        string Name;
        string Description;
        string URI;
        uint Type;
        uint DeathPoint;
    }
}