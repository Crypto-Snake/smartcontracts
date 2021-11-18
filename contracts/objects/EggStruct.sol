//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

abstract contract EggStruct {
    struct Egg {
        string Name;
        string Description;
        string URI;
        uint SnakeType;
        uint Price;
        uint HatchingPeriod;
    }
}