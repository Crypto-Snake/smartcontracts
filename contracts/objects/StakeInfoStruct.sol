//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

abstract contract StakeInfoStruct {
    struct StakeInfo {
        uint256 tokenId;
        uint256 rewardRate;
        uint256 stakeAmount;
        bool isLocked;
    }
}