//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.9;

import "../interfaces/IBEP20.sol";
import "../interfaces/IPair.sol";
import "../utils/RescueManager.sol";
import "../utils/Initializable.sol";
import "../utils/ReentrancyGuard.sol";
import "../utils/Convertable.sol";
import "../objects/farming/FarmingObjects.sol";

contract FarmingStorage is Initializable, ReentrancyGuard, Convertable, RescueManager, FarmingObjects {
    address internal _implementationAddress;
    uint public version;

    IPair public lpToken;

    mapping(uint => StakingPool) public pools;

    mapping(address => uint) public nonces;
    mapping(address => mapping(uint => FarmingInfo)) public stakeInfo;

    event UpdatePoolProperties(uint indexed poolId, address indexed stakingToken, address indexed rewardToken, uint minRate, uint maxRate, uint maxPoolSize, uint lockPeriod);
    event UpdateLPToken(address token);
    
    function updatePoolProperties(uint poolId, address stakingToken, address rewardToken, uint minRate, uint maxRate, uint maxPoolSize, uint lockPeriod) external onlyOwner {
        require(Address.isContract(stakingToken), "stakingToken is not a contract");
        require(Address.isContract(rewardToken), "rewardToken is not a contract");

        pools[poolId].StakingToken = stakingToken;
        pools[poolId].RewardToken = rewardToken;
        pools[poolId].MinRate = minRate;
        pools[poolId].MaxRate = maxRate;
        pools[poolId].MaxPoolSize = maxPoolSize;
        pools[poolId].LockPeriod = lockPeriod;
        emit UpdatePoolProperties(poolId, stakingToken, rewardToken, minRate, maxRate, maxPoolSize, lockPeriod);
    }

    function updateLPToken(address token) external onlyOwner {
        require(Address.isContract(token), "token is not a contract");
        lpToken = IPair(token);

        emit UpdateLPToken(token);
    }
}