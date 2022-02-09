//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.9;

abstract contract FarmingInfoStruct {
    struct FarmingInfo {
        uint Amount;
        uint Rate;
        uint CurrentPoolSize;
        uint LockPeriod;
        uint StartTimestamp;
        uint EndTimestamp;
    }
}