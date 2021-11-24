//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

abstract contract SnakeStatsStruct {
    struct SnakeStats {
        uint Id;
        uint Type;
        uint HatchingTime;
        uint APR;
        uint StakeAmount;
        uint GameBalance;
        uint TimesFeeded;
        uint TimesFeededMoreThanTreshold;
        uint PreviousFeededTime;
        uint LastFeededTime;
        uint TimesRateUpdated;
        bool IsDead;
        uint DestroyLock;
    }
}