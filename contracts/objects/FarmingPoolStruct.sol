//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.9;

abstract contract FarmingPoolStruct {
    struct FarmingPool {
        address StakingToken;
        uint MinRate;
        uint MaxRate;
        uint CurrentPoolSize;
        uint MaxPoolSize;
        uint LockPeriod;
    }
}