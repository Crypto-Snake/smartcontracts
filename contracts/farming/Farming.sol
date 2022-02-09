//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.9;

import "./FarmingStorage.sol";
import "../utils/Address.sol";
import "../utils/TransferHelper.sol";

contract Farming is FarmingStorage {
    
    event Stake(address indexed user, uint nonce, uint indexed stakeAmount, uint indexed rate, uint stakeTimestamp);
    event Withdraw(address indexed user, uint nonce, uint indexed witdrawAmount, uint reward, uint withdrawTimestamp);

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
        return _maxRate - (_maxRate * _totalSupply * _maxTotalSupply);
    }

    function earned(uint nonce) public view returns (uint) {
        FarmingInfo memory info = farmingInfo[msg.sender][nonce];
        require(info.Amount != 0, "Farming: Stake amount is equal to 0");
        require(info.EndTimestamp == 0, "Farming: Stake already withdrawn");
        
        return info.Amount * info.Rate * (block.timestamp - info.StartTimestamp) / info.LockPeriod;
    }

    function stake(uint amount) external {
        require(amount > 0, "Farming: Stake amount is equal to 0");
        uint stakeNonce = nonces[msg.sender]++;
        uint rate = getCurrentRate();

        FarmingInfo memory info = FarmingInfo(amount, rate, _totalSupply, _lockPeriod, block.timestamp, 0);
        farmingInfo[msg.sender][stakeNonce] = info;

        TransferHelper.safeTransferFrom(address(_stakingToken), msg.sender, address(this), amount);
        _totalSupply += amount;

        emit Stake(msg.sender, stakeNonce, amount, rate, block.timestamp);
    }

    function withdraw(uint nonce) external {
        FarmingInfo memory info = farmingInfo[msg.sender][nonce];
        require(info.Amount != 0, "Farming: Stake amount is equal to 0");
        require(info.EndTimestamp == 0, "Farming: Stake already withdrawn");
        require(info.StartTimestamp + info.LockPeriod < block.timestamp, "Farming: Stake is locked");

        farmingInfo[msg.sender][nonce].EndTimestamp = block.timestamp;
        _totalSupply -= info.Amount;

        uint reward = earned(nonce);
        uint withdrawAmount = info.Amount + reward;

        TransferHelper.safeTransfer(address(_stakingToken), msg.sender, withdrawAmount);
        emit Withdraw(msg.sender, nonce, withdrawAmount, reward, block.timestamp);
    }
}