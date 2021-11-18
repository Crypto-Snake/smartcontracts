//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

abstract contract EggStatsStruct {
    struct EggStats {
        uint Id;
        uint PurchasingAmount;
        uint PurchasingTime;
        uint SnakeType;
    }
}