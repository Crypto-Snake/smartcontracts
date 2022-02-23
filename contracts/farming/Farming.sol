//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.9;

import "./FarmingStorage.sol";
import "../utils/Address.sol";
import "../utils/TransferHelper.sol";

contract Farming is FarmingStorage {
    
    event Stake(address indexed user, uint nonce, uint indexed stakeAmount, uint indexed rate, uint stakeTimestamp);
    event Withdraw(address indexed user, uint nonce, uint indexed withdrawAmount, uint withdrawTimestamp);
    event ClaimReward(address indexed user, uint nonce, uint indexed reward, uint claimRewardTimestamp);
    event UpdatePoolProperties(address indexed stakingToken, uint indexed poolId, uint minRate, uint maxRate, uint maxPoolSize, uint lockPeriod);

    function famingPool(uint id) external view returns (FarmingPool memory) {
        return pools[id];
    }

    function getCurrentPoolRate(uint id) public view returns (uint) {
        FarmingPool memory farmingPool = pools[id];

        if(farmingPool.CurrentPoolSize > farmingPool.MaxPoolSize) {
            return farmingPool.MaxRate;
        } else {
            return farmingPool.MaxRate - (farmingPool.MaxRate * farmingPool.CurrentPoolSize / farmingPool.MaxPoolSize);
        }
    }

    function earned(address user, uint nonce) public view returns (uint) {
        FarmingInfo memory info = farmingInfo[user][nonce];
        require(info.Amount != 0, "Farming: Stake amount is equal to 0");
        require(info.WithdrawTimestamp == 0, "Farming: Stake already withdrawn");
        
        return _earned(info);
    }

    function totalEarned(address user) public view returns (uint) {
        uint total;

        for (uint256 i = 0; i < nonces[user]; i++) {
            FarmingInfo memory info = farmingInfo[user][i];

            if(info.WithdrawTimestamp == 0) {
                total += _earned(info);
            }
        }

        return total;
    }

    function stake(uint amount, uint pool) external nonReentrant {
        _stake(amount, pool);
    }

    function withdrawAndClaimReward(uint nonce) external nonReentrant {
        _claimReward(nonce); 
        _withdraw(nonce);
    }   

    function claimReward(uint nonce) external nonReentrant {
        _claimReward(nonce);
    }

    function claimTotalReward() external nonReentrant {
        for (uint256 i = 0; i < nonces[msg.sender]; i++) {
            FarmingInfo memory info = farmingInfo[msg.sender][i];

            if(info.WithdrawTimestamp == 0) {
                _claimReward(i);
            }
        }
    }

    function updatePoolProperties(address stakingToken, uint poolId, uint minRate, uint maxRate, uint maxPoolSize, uint lockPeriod) external onlyOwner {
        require(Address.isContract(stakingToken), "stakingToken is not a contract");

        pools[poolId].StakingToken = stakingToken;
        pools[poolId].MinRate = minRate;
        pools[poolId].MaxRate = maxRate;
        pools[poolId].MaxPoolSize = maxPoolSize;
        pools[poolId].LockPeriod = lockPeriod;
        emit UpdatePoolProperties(stakingToken, poolId, minRate, maxRate, maxPoolSize, lockPeriod);
    }

    function _stake(uint amount, uint poolId) internal {
        require(amount > 0, "Farming: Stake amount is equal to 0");
        FarmingPool memory farmingPool = pools[poolId];
        require(farmingPool.MinRate != 0, "Farming: pool does not exists");


        uint stakeNonce = nonces[msg.sender]++;
        uint rate = getCurrentPoolRate(poolId);

        FarmingInfo memory info = FarmingInfo(farmingPool.StakingToken, amount, poolId, rate, farmingPool.CurrentPoolSize, farmingPool.LockPeriod, block.timestamp, 0, 0);
        farmingInfo[msg.sender][stakeNonce] = info;

        TransferHelper.safeTransferFrom(farmingPool.StakingToken, msg.sender, address(this), amount);
        pools[poolId].CurrentPoolSize += amount;

        emit Stake(msg.sender, stakeNonce, amount, rate, block.timestamp);
    } 

    function _withdraw(uint nonce) internal {
        FarmingInfo memory info = farmingInfo[msg.sender][nonce];
        require(info.Amount != 0, "Farming: Stake amount is equal to 0");
        require(info.WithdrawTimestamp == 0, "Farming: Stake already withdrawn");
        require(info.StartTimestamp + info.LockPeriod < block.timestamp, "Farming: Stake is locked");

        farmingInfo[msg.sender][nonce].WithdrawTimestamp = block.timestamp;
        pools[info.Pool].CurrentPoolSize -= info.Amount;

        TransferHelper.safeTransfer(pools[info.Pool].StakingToken, msg.sender, info.Amount);
        emit Withdraw(msg.sender, nonce, info.Amount, block.timestamp);
    }

    function _claimReward(uint nonce) internal {
        FarmingInfo memory info = farmingInfo[msg.sender][nonce];
        require(info.Amount != 0, "Farming: Stake amount is equal to 0");
        require(info.WithdrawTimestamp == 0, "Farming: Stake already withdrawn");

        uint reward = earned(msg.sender, nonce);
        farmingInfo[msg.sender][nonce].LastClaimRewardTimestamp = block.timestamp;

        TransferHelper.safeTransfer(pools[info.Pool].StakingToken, msg.sender, reward);
        emit ClaimReward(msg.sender, nonce, reward, block.timestamp);
    }

    function _earned(FarmingInfo memory info) internal view returns (uint) {
        uint startPeriod = info.LastClaimRewardTimestamp != 0 ? info.LastClaimRewardTimestamp : info.StartTimestamp;
        uint endPeriod = info.StartTimestamp + info.LockPeriod;

        if(info.LockPeriod > 0 && endPeriod > block.timestamp) {
            return info.Amount * info.Rate * (endPeriod - startPeriod) / 365 days;
        } else {
            return info.Amount * info.Rate * (block.timestamp - startPeriod) / 365 days;
        }
    }
}