//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

interface ILockStakingRewardsPool {
    function earned(uint256 tokenId) external view returns (uint256);
    function totalSupply() external view returns (uint256);
    function balanceOf(uint256 tokenId) external view returns (uint256);
    function stakeFor(uint256 amount, uint256 tokenId, uint rate, bool isLocked) external;
    function getReward(uint tokenId, address receiver) external;
    function getRewardFor(uint tokenId, address receiver, bool stable, uint artifactId) external;
    function withdraw(uint256 tokenId, address receiver) external;
    function withdrawAndGetReward(uint256 tokenId, address receiver) external;
    function updateAmountForStake(uint tokenId, uint amount, bool increase) external;
    function updateStakeIsLocked(uint256 tokenId, bool isLocked) external;
}