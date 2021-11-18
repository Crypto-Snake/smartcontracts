//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "./utils/Address.sol";
import "./utils/RescueManager.sol";
import "./utils/ReentrancyGuard.sol";
import "./interfaces/IBEP20.sol";
import "./interfaces/ILockStakingRewardsPool.sol";
import "./interfaces/INFTManager.sol";
import "./objects/Objects.sol";
import "./objects/StakeObjects.sol";

contract LockStakingRewardsPool is ILockStakingRewardsPool, ReentrancyGuard, RescueManager, Objects, StakeObjects {

    IBEP20 public immutable stakingToken;
    INFTManager public nftManager;

    uint256 public constant rewardDuration = 365 days;
    uint public constant percentPrecision = 1e18;

    uint public pythonBonusRate = 1e16;
  
    mapping(uint256 => uint256) public stakeNonces;

    mapping(uint256 => mapping(uint256 => StakeInfo)) public stakeInfo;
    mapping(uint256 => TokenStakeInfo) public tokenStakeInfo;

    uint256 private _totalSupply;

    event Staked(uint256 indexed tokenId, uint256 amount);
    event Withdrawn(uint256 indexed tokenId, uint256 amount, address indexed to);
    event RewardPaid(uint256 indexed tokenId, uint256 reward, address indexed to);
    event UpdatePythonBonusRate(uint indexed rate);
    event UpdateNFTManager(address indexed nftManager);

    modifier onlyNFTManager {
        require(msg.sender == address(nftManager), "LockStakingReward: caller is not an NFT manager contract");
        _;
    }

    constructor(address _stakingToken) {
        require(Address.isContract(_stakingToken), "_stakingToken is not a contract");

        stakingToken = IBEP20(_stakingToken);
    }

    function totalSupply() external override view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(uint256 tokenId) public override view returns (uint256) {
        return tokenStakeInfo[tokenId].balance;
    }

    function getRate(uint256 tokenId) public view returns(uint totalRate) {
        uint totalAmountStaked = balanceOf(tokenId);

        for(uint i = 0; i < stakeNonces[tokenId]; i++) {
            StakeInfo memory stakeInfoLocal = stakeInfo[tokenId][i];

            if(stakeInfoLocal.stakeAmount != 0) {
                totalRate += (stakeInfoLocal.rewardRate) * stakeInfoLocal.stakeAmount / totalAmountStaked;
            }
        }
    }

    function earned(uint256 tokenId) public override view returns (uint256) {
        SnakeStats memory snakeStatsLocal = nftManager.getSnakeStats(tokenId);
        require(snakeStatsLocal.Type != 0, "LockStakingReward: Snake with provided id does not exists");

        uint rate = 0;

        if(snakeStatsLocal.Type == 3) {
            uint daysAfterHatching = (block.timestamp - snakeStatsLocal.HatchingTime) / 1 days;
            uint bonusRate = daysAfterHatching * pythonBonusRate;

            rate = (bonusRate + getRate(tokenId)) / percentPrecision;
        } else {
            rate = (getRate(tokenId)) / percentPrecision;
        }
        
        return (tokenStakeInfo[tokenId].balance * (block.timestamp - tokenStakeInfo[tokenId].weightedStakeDate) * rate) / (100 * rewardDuration);
    }

    function stakeFor(uint256 amount, uint256 tokenId, uint rate, bool isLocked) external override nonReentrant onlyNFTManager {
        _stake(amount, tokenId, rate, isLocked);
    }

    function withdraw(uint256 tokenId) public override nonReentrant onlyNFTManager {
        require(stakeInfo[tokenId][0].stakeAmount > 0, "LockStakingRewardsPool: This stake nonce was withdrawn");
        require(!stakeInfo[tokenId][0].isLocked, "LockStakingRewardsPool: Unable to withdraw locked staking");

        SnakeStats memory stats = nftManager.getSnakeStats(tokenId);

        address msgSenderLocal = msg.sender;
        uint256 amount = tokenStakeInfo[tokenId].balance + stats.GameBalance;

        _totalSupply -= amount;
        tokenStakeInfo[tokenId].balance -= amount;
        stats.GameBalance = 0;

        require(stakingToken.balanceOf(address(this)) > amount, "StakingRewardsPool: Not enough staking token on staking contract");
        TransferHelper.safeTransfer(address(stakingToken), msgSenderLocal, amount);

        uint currentNonce = stakeNonces[tokenId];

        for (uint256 nonce = 0; nonce <= currentNonce; nonce++) {
            stakeInfo[tokenId][nonce].stakeAmount = 0;
        }

        tokenStakeInfo[tokenId].isWithdrawn = true;
    
        emit Withdrawn(tokenId, amount, msgSenderLocal);
    }

    function withdrawAndGetReward(uint256 tokenId) external override onlyNFTManager {
        getReward(tokenId);
        withdraw(tokenId);
    }

    function getReward(uint256 tokenId) public override nonReentrant onlyNFTManager {
        require(!stakeInfo[tokenId][0].isLocked, "LockStakingRewardsPool: Unable to withdraw locked staking");
        
        address msgSenderLocal = msg.sender;
        uint256 reward = earned(tokenId);

        if (reward > 0) {
            tokenStakeInfo[tokenId].weightedStakeDate = block.timestamp;
            require(stakingToken.balanceOf(address(this)) > reward, "StakingRewardsPool: Not enough reward token on staking contract");
            TransferHelper.safeTransfer(address(stakingToken), msgSenderLocal, reward);

            emit RewardPaid(tokenId, reward, msgSenderLocal);
        }
    }

    function updateAmountForStake(uint tokenId, int amount) external override onlyNFTManager {
        uint nonce = stakeNonces[tokenId];
        uint uintAmount;
        
        if(amount < 0) {
            uintAmount = uint(amount * -1);
            uint left = uintAmount;

            for (uint256 n = nonce; n >= 0; n--) {
                uint nonceStakeAmount = stakeInfo[tokenId][n].stakeAmount;
                if(nonceStakeAmount < left) {
                    left -= nonceStakeAmount;
                    stakeInfo[tokenId][n].stakeAmount = 0;
                } else {
                    stakeInfo[tokenId][n].stakeAmount -= uintAmount;
                    break;
                }
            }

            tokenStakeInfo[tokenId].balance -= uintAmount;
        } else {
            uintAmount = uint(amount);
            stakeInfo[tokenId][nonce].stakeAmount += uintAmount;
            tokenStakeInfo[tokenId].balance += uintAmount;
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

    function _stake(uint256 amount, uint256 tokenId, uint rate, bool isLocked) private {
        require(amount > 0, "LockStakingRewardsPool: Stake amount must be grater than zero");
        TokenStakeInfo memory tokenStakeInfoLocal = tokenStakeInfo[tokenId];
        uint stakeNonce = stakeNonces[tokenId]++;
        
        _totalSupply += amount;
        uint previousAmount = tokenStakeInfoLocal.balance;
        uint newAmount = previousAmount + amount;
        tokenStakeInfo[tokenId].weightedStakeDate = tokenStakeInfoLocal.weightedStakeDate * previousAmount / newAmount + block.timestamp * amount / newAmount;
        tokenStakeInfo[tokenId].balance = newAmount;
        stakeInfo[tokenId][stakeNonce].stakeAmount = amount;

        stakeInfo[tokenId][stakeNonce].tokenId = tokenId;
        stakeInfo[tokenId][stakeNonce].rewardRate = rate;
        stakeInfo[tokenId][stakeNonce].isLocked = isLocked;
        
        emit Staked(tokenId, amount);
    }
}