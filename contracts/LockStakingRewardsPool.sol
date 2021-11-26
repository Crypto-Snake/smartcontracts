//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "./utils/Address.sol";
import "./utils/RescueManager.sol";
import "./utils/ReentrancyGuard.sol";
import "./utils/Convertable.sol";
import "./interfaces/IBEP20.sol";
import "./interfaces/ILockStakingRewardsPool.sol";
import "./interfaces/INFTManager.sol";
import "./objects/Objects.sol";
import "./objects/StakeObjects.sol";

contract LockStakingRewardsPool is ILockStakingRewardsPool, ReentrancyGuard, RescueManager, Objects, StakeObjects, Convertable {

    IBEP20 public immutable stakingToken;
    IBEP20 public stableCoin;
    INFTManager public nftManager;

    uint256 public constant rewardDuration = 365 days;

    uint public pythonBonusRate = 1e16;
  
    mapping(uint256 => uint256) public stakeNonces;

    mapping(uint256 => mapping(uint256 => StakeInfo)) public stakeInfo;
    mapping(uint256 => TokenStakeInfo) public tokenStakeInfo;

    uint256 private _totalSupply;

    event Staked(uint256 indexed tokenId, uint256 amount);
    event Withdrawn(uint256 indexed tokenId, uint256 amount, address indexed to);
    event RewardPaid(uint256 indexed tokenId, uint256 reward, address indexed rewardToken, address indexed to);
    event UpdatePythonBonusRate(uint indexed rate);
    event UpdateNFTManager(address indexed nftManager);
    event UpdateStableCoin(address indexed stableCoin);

    modifier onlyNFTManager {
        require(msg.sender == address(nftManager), "LockStakingReward: caller is not an NFT manager contract");
        _;
    }

    constructor(address _stakingToken, address _stableCoin) {
        require(Address.isContract(_stakingToken), "_stakingToken is not a contract");
        require(Address.isContract(_stableCoin), "_stableCoin is not a contract");
        
        stakingToken = IBEP20(_stakingToken);
        stableCoin = IBEP20(_stableCoin);
    }

    function totalSupply() external override view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(uint256 tokenId) public override view returns (uint256) {
        return tokenStakeInfo[tokenId].balance;
    }

    function getRate(uint256 tokenId) public view returns(uint totalRate) {
        uint totalAmountStaked = tokenStakeInfo[tokenId].accumulatedBalance;

        for (uint i = 0; i < stakeNonces[tokenId]; i++) {
            StakeInfo memory stakeInfoLocal = stakeInfo[tokenId][i];

            if (stakeInfoLocal.stakeAmount > 0) {
                totalRate += (stakeInfoLocal.rewardRate) * stakeInfoLocal.stakeAmount / totalAmountStaked;
            }
        }
    }

    function earned(uint256 tokenId) public override view returns (uint256) {
        SnakeStats memory snakeStatsLocal = nftManager.getSnakeStats(tokenId);
        require(snakeStatsLocal.Type != 0, "LockStakingReward: Snake with provided id does not exists");

        uint rate = 0;

        if (snakeStatsLocal.Type == 3) {
            uint daysAfterHatching = (block.timestamp - snakeStatsLocal.HatchingTime) / 1 days;
            uint bonusRate = daysAfterHatching * pythonBonusRate;

            rate = bonusRate + getRate(tokenId);
        } else {
            rate = getRate(tokenId);
        }
        
        return (tokenStakeInfo[tokenId].balance * (block.timestamp - tokenStakeInfo[tokenId].weightedStakeDate) * rate) / (percentPrecision * rewardDuration);
    }

    function stakeFor(uint256 amount, uint256 tokenId, uint rate, bool isLocked) external override nonReentrant onlyNFTManager {
        _stake(amount, tokenId, rate, isLocked);
    }

    function withdraw(uint256 tokenId, address receiver) public override nonReentrant onlyNFTManager {
        require(stakeInfo[tokenId][0].stakeAmount > 0, "LockStakingRewardsPool: This stake nonce was withdrawn");
        require(!stakeInfo[tokenId][0].isLocked, "LockStakingRewardsPool: Unable to withdraw locked staking");

        SnakeStats memory stats = nftManager.getSnakeStats(tokenId);

        uint stakeBalance = tokenStakeInfo[tokenId].balance;
        uint256 amount = stakeBalance + stats.GameBalance;

        _totalSupply -= stakeBalance;
        tokenStakeInfo[tokenId].balance = 0;
        tokenStakeInfo[tokenId].accumulatedBalance = 0;
        stats.GameBalance = 0;

        require(stakingToken.balanceOf(address(this)) > amount, "StakingRewardsPool: Not enough staking token on staking contract");
        TransferHelper.safeTransfer(address(stakingToken), receiver, amount);

        uint currentNonce = stakeNonces[tokenId];

        for (uint256 nonce = 0; nonce <= currentNonce; nonce++) {
            stakeInfo[tokenId][nonce].stakeAmount = 0;
        }

        tokenStakeInfo[tokenId].isWithdrawn = true;
    
        emit Withdrawn(tokenId, amount, receiver);
    }

    function withdrawAndGetReward(uint256 tokenId, address receiver) external override onlyNFTManager {
        getReward(tokenId, receiver);
        withdraw(tokenId, receiver);
    }

    function getRewardFor(uint256 tokenId, address receiver, bool stable) public nonReentrant onlyNFTManager {
        require(!stakeInfo[tokenId][0].isLocked, "LockStakingRewardsPool: Unable to withdraw locked staking");
        
        uint256 reward = earned(tokenId);

        require(reward > 0, "LockStakingRewardsPool: Reward is equal to zero");

        if (stable) {
            uint stableCoinEquivalentReward = getTokenEquivalentAmount(address(stableCoin), reward);
            require(stableCoin.balanceOf(address(this)) > stableCoinEquivalentReward, "StakingRewardsPool: Not enough stable coin on staking contract");
            TransferHelper.safeTransfer(address(stableCoin), receiver, stableCoinEquivalentReward);
            emit RewardPaid(tokenId, stableCoinEquivalentReward, address(stableCoin), receiver);
        } else {
            require(stakingToken.balanceOf(address(this)) > reward, "StakingRewardsPool: Not enough reward token on staking contract");
            TransferHelper.safeTransfer(address(stakingToken), receiver, reward);
            emit RewardPaid(tokenId, reward, address(stakingToken), receiver);
        }

        tokenStakeInfo[tokenId].weightedStakeDate = block.timestamp;
    }

    function getReward(uint256 tokenId, address receiver) public override nonReentrant onlyNFTManager {
        require(!stakeInfo[tokenId][0].isLocked, "LockStakingRewardsPool: Unable to withdraw locked staking");
        
        uint256 reward = earned(tokenId);

        if (reward > 0) {
            tokenStakeInfo[tokenId].weightedStakeDate = block.timestamp;
            require(stakingToken.balanceOf(address(this)) > reward, "StakingRewardsPool: Not enough reward token on staking contract");
            TransferHelper.safeTransfer(address(stakingToken), receiver, reward);

            emit RewardPaid(tokenId, reward, address(stakingToken), receiver);
        }
    }

    function updateAmountForStake(uint tokenId, uint amount, bool increase) external override onlyNFTManager {
        uint nonce = stakeNonces[tokenId];
        
        uint newAmount;
        if (increase) {
            newAmount = stakeInfo[tokenId][nonce].stakeAmount + amount;
            stakeInfo[tokenId][nonce].stakeAmount = newAmount;
            tokenStakeInfo[tokenId].balance += amount;
            tokenStakeInfo[tokenId].accumulatedBalance += amount;
            if (nonce > 0)  
                tokenStakeInfo[tokenId].weightedStakeDate = 
                    tokenStakeInfo[tokenId].weightedStakeDate * stakeInfo[tokenId][nonce - 1].stakeAmount / newAmount 
                    + block.timestamp * amount / newAmount;
        } else {
            uint balance = stakeInfo[tokenId][nonce].stakeAmount;
            require (balance >= amount, "StakingRewardsPool: Balance is lower than decrease amount");
            unchecked {
                newAmount = balance - amount;
                stakeInfo[tokenId][nonce].stakeAmount = newAmount;
                tokenStakeInfo[tokenId].balance -= amount;
                tokenStakeInfo[tokenId].accumulatedBalance -= amount;
            }
            if (nonce > 0)  
                tokenStakeInfo[tokenId].weightedStakeDate = 
                    tokenStakeInfo[tokenId].weightedStakeDate * stakeInfo[tokenId][nonce - 1].stakeAmount / newAmount 
                    - block.timestamp * amount / newAmount;
        }
    }    

    function updateStakeIsLocked(uint256 tokenId, bool isLocked) external override onlyNFTManager {
        stakeInfo[tokenId][0].isLocked = isLocked;
    }

    function updatePythonBonusRate(uint rate) external onlyOwner {
        pythonBonusRate = rate;
    }

    function updateNFTManager(address _nftManager) external onlyOwner {
        require(Address.isContract(_nftManager), "SnakeEggsShop: _nftManager is not a contract");
        nftManager = INFTManager(_nftManager);
        emit UpdateNFTManager(_nftManager);
    }

    function updateStableCoin(address _stableCoin) external onlyOwner {
        require(Address.isContract(_stableCoin), "SnakeEggsShop: _stableCoin is not a contract");
        stableCoin = IBEP20(_stableCoin);
        emit UpdateStableCoin(_stableCoin);
    }

    function _stake(uint256 amount, uint256 tokenId, uint rate, bool isLocked) private {
        require(amount > 0, "LockStakingRewardsPool: Stake amount must be grater than zero");
        TokenStakeInfo memory tokenStakeInfoLocal = tokenStakeInfo[tokenId];
        uint stakeNonce = stakeNonces[tokenId]++;
        
        _totalSupply += amount;
        uint previousAmount = tokenStakeInfoLocal.balance;
        uint newAmount = previousAmount + amount;
        tokenStakeInfo[tokenId].weightedStakeDate = tokenStakeInfoLocal.weightedStakeDate * previousAmount / newAmount + block.timestamp * amount / newAmount;
        tokenStakeInfo[tokenId].balance = newAmount;
        tokenStakeInfo[tokenId].accumulatedBalance += amount;
        stakeInfo[tokenId][stakeNonce].stakeAmount = newAmount;

        stakeInfo[tokenId][stakeNonce].tokenId = tokenId;
        stakeInfo[tokenId][stakeNonce].rewardRate = rate;
        stakeInfo[tokenId][stakeNonce].isLocked = isLocked;
        
        emit Staked(tokenId, amount);
    }
}