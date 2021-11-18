//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

interface ILockStakingRewardsPool {
    function earned(uint256 tokenId) external view returns (uint256);
    function totalSupply() external view returns (uint256);
    function balanceOf(uint256 tokenId) external view returns (uint256);
    function stakeFor(uint256 amount, uint256 tokenId, uint rate, bool isLocked) external;
    function getReward(uint256 tokenId) external;
    function withdraw(uint256 tokenId) external;
    function withdrawAndGetReward(uint256 tokenId) external;
    function updateAmountForStake(uint tokenId, int stakeAmount) external;
    function updateStakeIsLocked(uint256 tokenId, bool isLocked) external;
}