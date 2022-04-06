//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.9;

abstract contract FarmingInfoStruct {
    struct FarmingInfo {
        address StakingToken;
        uint Amount;
        uint EquivalentAmount;
        uint Pool;
        uint Rate;
        uint CurrentPoolSize;
        uint LockPeriod;
        uint StartTimestamp;
        uint LastClaimRewardTimestamp;
        uint WithdrawTimestamp;
    }
}