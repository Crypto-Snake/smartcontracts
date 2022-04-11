//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.9;

import "./StakingStorage.sol";
import "../utils/Address.sol";
import "../utils/TransferHelper.sol";

contract Staking is StakingStorage {
    
    event Stake(address indexed user, uint nonce, uint indexed stakeAmount, uint indexed rate, uint stakeTimestamp);
    event Withdraw(address indexed user, uint nonce, uint indexed withdrawAmount, uint withdrawTimestamp);
    event ClaimReward(address indexed user, uint nonce, uint indexed reward, uint claimRewardTimestamp);

    function initialize(address _snakeToken) external initializer {
        require(Address.isContract(_snakeToken), "_snakeToken is not a contract");

        snakeToken = _snakeToken;
    }

    function stakingPool(uint id) external view returns (StakingPool memory) {
        return pools[id];
    }

    function getCurrentPoolRate(uint id) public view returns (uint) {
        StakingPool memory pool = pools[id];
        uint difference = (pool.MaxRate - pool.MinRate) * pool.CurrentPoolSize / pool.MaxPoolSize;
        
        uint rate = difference > pool.MaxRate ? pool.MinRate : pool.MaxRate - difference;
        return rate;  
    }

    function earned(address user, uint nonce) public view returns (uint) {
        FarmingInfo memory info = stakeInfo[user][nonce];
        require(info.Amount != 0, "Staking: Stake amount is equal to 0");
        require(info.WithdrawTimestamp == 0, "Staking: Stake already withdrawn");
        
        return _earned(info);
    }

    function totalEarned(address user) public view returns (uint) {
        uint total;

        for (uint256 i = 0; i < nonces[user]; i++) {
            FarmingInfo memory info = stakeInfo[user][i];

            if(info.WithdrawTimestamp == 0) {
                total += _earned(info);
            }
        }

        return total;
    }
    
    function totalStaked(address user) external view returns (uint) {
        uint total;

        for (uint256 i = 0; i < nonces[user]; i++) {
            FarmingInfo memory info = stakeInfo[user][i];

            if(info.WithdrawTimestamp == 0) {
                total += info.Amount;
            }
        }

        return total;
    }

    function averageRate(address user) external view returns (uint) {
        uint totalRate;
        uint activeStakes;

        for (uint256 i = 0; i < nonces[user]; i++) {
            FarmingInfo memory info = stakeInfo[user][i];

            if(info.WithdrawTimestamp == 0) {
                totalRate += info.Rate;
                activeStakes += 1;
            }
        }

        return totalRate / activeStakes;
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
            FarmingInfo memory info = stakeInfo[msg.sender][i];

            if(info.WithdrawTimestamp == 0) {
                _claimReward(i);
            }
        }
    }

    function _stake(uint amount, uint poolId) internal {
        require(amount > 0, "Staking: Stake amount is equal to 0");
        StakingPool memory pool = pools[poolId];
        require(pool.MinRate != 0, "Staking: pool does not exists");

        uint equivalentAmount = amount;

        uint stakeNonce = nonces[msg.sender]++;
        uint rate = getCurrentPoolRate(poolId);

        FarmingInfo memory info = FarmingInfo(pool.StakingToken, amount, equivalentAmount, poolId, rate, pool.CurrentPoolSize, pool.LockPeriod, block.timestamp, 0, 0);
        stakeInfo[msg.sender][stakeNonce] = info;

        TransferHelper.safeTransferFrom(pool.StakingToken, msg.sender, address(this), amount);
        pools[poolId].CurrentPoolSize += amount;

        emit Stake(msg.sender, stakeNonce, amount, rate, block.timestamp);
    } 

    function _withdraw(uint nonce) internal {
        FarmingInfo memory info = stakeInfo[msg.sender][nonce];
        require(info.Amount != 0, "Staking: Stake amount is equal to 0");
        require(info.WithdrawTimestamp == 0, "Staking: Stake already withdrawn");
        require(info.StartTimestamp + info.LockPeriod < block.timestamp, "Staking: Stake is locked");

        stakeInfo[msg.sender][nonce].WithdrawTimestamp = block.timestamp;
        pools[info.Pool].CurrentPoolSize -= info.Amount;

        TransferHelper.safeTransfer(pools[info.Pool].StakingToken, msg.sender, info.Amount);
        emit Withdraw(msg.sender, nonce, info.Amount, block.timestamp);
    }

    function _claimReward(uint nonce) internal {
        FarmingInfo memory info = stakeInfo[msg.sender][nonce];
        require(info.Amount != 0, "Staking: Stake amount is equal to 0");
        require(info.WithdrawTimestamp == 0, "Staking: Stake already withdrawn");

        uint reward = earned(msg.sender, nonce);
        stakeInfo[msg.sender][nonce].LastClaimRewardTimestamp = block.timestamp;

        TransferHelper.safeTransfer(pools[info.Pool].StakingToken, msg.sender, reward);
        emit ClaimReward(msg.sender, nonce, reward, block.timestamp);
    }

    function _earned(FarmingInfo memory info) internal view returns (uint) {
        uint startPeriod = info.LastClaimRewardTimestamp != 0 ? info.LastClaimRewardTimestamp : info.StartTimestamp;
        uint endPeriod = info.StartTimestamp + info.LockPeriod;
        uint earningPeriod = 0;

        if(endPeriod > startPeriod) {
            earningPeriod = info.LockPeriod > 0 && block.timestamp > endPeriod ? endPeriod - startPeriod : block.timestamp - startPeriod;
        }

        return info.Amount * info.Rate / 1e20 * earningPeriod / 365 days;
    }
}