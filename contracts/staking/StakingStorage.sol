//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.9;

import "../interfaces/IBEP20.sol";
import "../utils/RescueManager.sol";
import "../utils/Initializable.sol";
import "../utils/ReentrancyGuard.sol";
import "../objects/farming/FarmingObjects.sol";

contract StakingStorage is Initializable, ReentrancyGuard, RescueManager, FarmingObjects {
    address internal _implementationAddress;
    uint public version;

    address public snakeToken;

    mapping(uint => StakingPool) public pools;

    mapping(address => uint) public nonces;
    mapping(address => mapping(uint => FarmingInfo)) public stakeInfo;

    event UpdatePoolProperties(uint indexed poolId, address indexed stakingToken, address indexed rewardToken, uint minRate, uint maxRate, uint maxPoolSize, uint lockPeriod);
    event UpdateSnakeToken(address indexed token);
    
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

    function updateSnakeToken(address token) external onlyOwner {
        require(Address.isContract(token), "token is not a contract");
        snakeToken = token;
        emit UpdateSnakeToken(token);
    }
}