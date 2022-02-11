//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.9;

import "./FarmingStorage.sol";
import "../utils/Address.sol";
import "../utils/TransferHelper.sol";

contract Farming is FarmingStorage {
    
    event Stake(address indexed user, uint nonce, uint indexed stakeAmount, uint indexed rate, uint stakeTimestamp);
    event Withdraw(address indexed user, uint nonce, uint indexed withdrawAmount, uint withdrawTimestamp);
    event ClaimReward(address indexed user, uint nonce, uint indexed reward, uint claimRewardTimestamp);
    event UpdateLockPeriod(uint indexed lockPeriod);

    function initialize(address stakingToken_, uint minRate_, uint maxRate_, uint maxTotalSupply_, uint lockPeriod_) external initializer {
        require(Address.isContract(stakingToken_), "stakingToken is not a contract");
        
        _stakingToken = IBEP20(stakingToken_);
        _minRate = minRate_;
        _maxRate = maxRate_;
        _maxTotalSupply = maxTotalSupply_;
        _lockPeriod = lockPeriod_;
    }

    function stakingToken() external view returns (address) {
        return address(_stakingToken);
    }

    function minRate() external view returns (uint) {
        return _minRate;
    }

    function maxRate() external view returns (uint) {
        return _maxRate;
    }

    function maxTotalSupply() external view returns (uint) {
        return _maxTotalSupply;
    }

    function totalSupply() external view returns (uint) {
        return _totalSupply;
    }

    function lockPeriod() external view returns (uint) {
        return _lockPeriod;
    }

    function getCurrentRate() public view returns (uint) {
        if(_totalSupply > _maxTotalSupply) {
            return _maxRate;
        } else {
            return _maxRate - (_maxRate * _totalSupply * _maxTotalSupply);
        }
    }

    function earned(uint nonce) public view returns (uint) {
        FarmingInfo memory info = farmingInfo[msg.sender][nonce];
        require(info.Amount != 0, "Farming: Stake amount is equal to 0");
        require(info.WithdrawTimestamp == 0, "Farming: Stake already withdrawn");
        
        return _earned(info);
    }

    function totalEarned() public view returns (uint) {
        uint total;

        for (uint256 i = 0; i < nonces[msg.sender]; i++) {
            FarmingInfo memory info = farmingInfo[msg.sender][i];

            if(info.WithdrawTimestamp == 0) {
                total += _earned(info);
            }
        }

        return total;
    }

    function stake(uint amount) external nonReentrant {
        require(amount > 0, "Farming: Stake amount is equal to 0");
        uint stakeNonce = nonces[msg.sender]++;
        uint rate = getCurrentRate();

        FarmingInfo memory info = FarmingInfo(amount, rate, _totalSupply, _lockPeriod, block.timestamp, 0, 0);
        farmingInfo[msg.sender][stakeNonce] = info;

        TransferHelper.safeTransferFrom(address(_stakingToken), msg.sender, address(this), amount);
        _totalSupply += amount;

        emit Stake(msg.sender, stakeNonce, amount, rate, block.timestamp);
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

    function updateLockPeriod(uint lockPeriod_) external onlyOwner {
        _lockPeriod = lockPeriod_;
        emit UpdateLockPeriod(lockPeriod_);
    }

    function _withdraw(uint nonce) internal {
        FarmingInfo memory info = farmingInfo[msg.sender][nonce];
        require(info.Amount != 0, "Farming: Stake amount is equal to 0");
        require(info.WithdrawTimestamp == 0, "Farming: Stake already withdrawn");
        require(info.StartTimestamp + info.LockPeriod < block.timestamp, "Farming: Stake is locked");

        farmingInfo[msg.sender][nonce].WithdrawTimestamp = block.timestamp;
        _totalSupply -= info.Amount;

        TransferHelper.safeTransfer(address(_stakingToken), msg.sender, info.Amount);
        emit Withdraw(msg.sender, nonce, info.Amount, block.timestamp);
    }

    function _claimReward(uint nonce) internal {
        FarmingInfo memory info = farmingInfo[msg.sender][nonce];
        require(info.Amount != 0, "Farming: Stake amount is equal to 0");
        require(info.WithdrawTimestamp == 0, "Farming: Stake already withdrawn");

        uint reward = earned(nonce);
        farmingInfo[msg.sender][nonce].LastClaimRewardTimestamp = block.timestamp;

        TransferHelper.safeTransfer(address(_stakingToken), msg.sender, reward);
        emit ClaimReward(msg.sender, nonce, reward, block.timestamp);
    }

    function _earned(FarmingInfo memory info) internal view returns (uint) {
        uint endPeriod = info.LastClaimRewardTimestamp != 0 ? info.LastClaimRewardTimestamp : info.StartTimestamp;
        return info.Amount * info.Rate * (block.timestamp - endPeriod) / info.LockPeriod;
    }
}