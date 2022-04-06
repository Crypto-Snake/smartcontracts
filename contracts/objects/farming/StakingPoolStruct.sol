//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.9;

abstract contract StakingPoolStruct {
    struct StakingPool {
        address StakingToken;
        address RewardToken;
        uint MinRate;
        uint MaxRate;
        uint CurrentPoolSize;
        uint MaxPoolSize;
        uint LockPeriod;
    }
}