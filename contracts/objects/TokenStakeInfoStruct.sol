//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

abstract contract TokenStakeInfoStruct {
    struct TokenStakeInfo {
        uint256 weightedStakeDate;
        uint256 balance;
        uint256 accumulatedBalance;
        bool isWithdrawn;
    }
}