//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

contract MergedSnake {

    //SnakeEggsShop
    event BuyEgg(address indexed buyer, address receiver, uint eggId, uint typeId, address indexed token, uint indexed purchaseAmount, uint purchaseTime);

    function buyEgg(uint typeId, address purchaseToken, uint purchaseTokenAmount) external {}
    function buyEggFor(uint typeId, address purchaseToken, uint purchaseTokenAmount, address receiver) external {}

    //SnakeArtifactsShop
    event BuyArtifact(address indexed buyer, uint indexed artifactId, address indexed token, uint artifactCount, uint totalEquivalentPrice);

    function buyArtifact(uint id, address purchaseToken, uint count) external {}

    //StakingPool
    event Staked(uint256 indexed tokenId, uint256 amount);
    event Withdrawn(uint256 indexed tokenId, uint256 amount, address indexed to);
    event RewardPaid(uint256 indexed tokenId, uint256 reward, address indexed rewardToken, address indexed to, uint artifactId);

    function stakeFor(uint256 amount, uint256 tokenId, uint rate, bool isLocked) external {}
    function withdraw(uint256 tokenId, address receiver) external {}
    function withdrawAndGetReward(uint256 tokenId, address receiver) external {}
    function getRewardFor(uint256 tokenId, address receiver, bool stable, uint artifactId) external {}
    function getReward(uint256 tokenId, address receiver) external {}
    function updateAmountForStake(uint tokenId, uint amount, bool increase) external {}
    function updateStakeIsLocked(uint256 tokenId, bool isLocked) external {}

    //NFTManager

    event HatchEgg(uint indexed tokenId);
    event UpdateBonusStakeRate(uint indexed snakeId, uint oldStakeRate, uint newStakeRate, address indexed updater);
    event UpdateStakeIsDead(uint indexed snakeId, uint artifactId);
    event DestroySnake(uint indexed tokenId);
    event UpdateStakeAmount(uint indexed snakeId, uint oldStakeAmount, uint newStakeAmount, address indexed updater, uint indexed artifactId);
    event UpdateGameBalance(uint indexed snakeId, uint oldGameBalance, uint newGameBalance, address indexed updater, uint indexed artifactId);
    event ApplyMysteryBoxArtifact(uint indexed snakeId, uint applyingTime, address indexed user);
    event ApplyDiamondArtifact(uint indexed snakeId, uint applyingTime, address indexed user);
    event ApplyBombArtifact(uint indexed snakeId, uint applyingTime, address indexed user);
    event ApplyMouseArtifact(uint indexed snakeId, uint stakeAmountBonus, uint applyingTime, address indexed user);
    event ApplyTrophyArtifact(uint indexed snakeId, uint applyingTime, address indexed user);
    event ApplyRainbowUnicornArtifact(uint indexed snakeId, uint applyingTime, address indexed user);
    event ApplySnakeHunterArtifact(uint indexed snakeId, uint applyingTime, address indexed user);
    event ApplySnakeCharmerArtifact(uint indexed snakeId, uint applyingTime, address indexed user);
    event ApplySnakeTimeArtifact(uint indexed snakeId, uint applyingTime, address indexed user);
    event ApplyShadowSnakeArtifact(uint indexed snakeId, uint stakeAmountBonus, uint applyingTime, address indexed user);

    function applyArtifact(uint snakeId, uint artifactId) external {}

    function claimReward(uint snakeId, uint artifactId) external {}

    function applyShadowSnakeBySign(uint snakeId, uint updateAmount, uint lockPeriod, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external {}

    function hatchEgg(uint tokenId) external {}

    function feedSnake(uint snakeId, address token, uint amount) external {}

    function destroySnake(uint256 tokenId) external {}

    function sleepSnake(uint snakeId) external {}

    function wakeSnake(uint snakeId) external {}

    function applyGameResultsBySign(uint snakeId, uint stakeAmount, uint gameBalance, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external {}

    //P2P

    event NewTradeSingle(address indexed user, address indexed proposedAsset, uint proposedAmount, uint proposedTokenId, address indexed askedAsset, uint askedAmount, uint askedTokenId, uint deadline, uint tradeId);
    event SupportTrade(uint indexed tradeId, address indexed counterparty);
    event CancelTrade(uint indexed tradeId);
    event WithdrawOverdueAsset(uint indexed tradeId);
    event CancelOrWithdrawOverdueAssetTrade(uint indexed tradeId);

    function createTrade721to20(address proposedAsset, uint tokenId, address askedAsset, uint askedAmount, uint deadline) external returns (uint tradeId) {}

    function createTrade1155to20(address proposedAsset, uint proposedAmount, uint proposedTokenId, address askedAsset, uint askedAmount, uint deadline) external returns (uint tradeId) {}

    function supportTradeSingle(uint tradeId) external {}

    function cancelTrade(uint tradeId) external {}

    function cancelTradeOrWithdrawOverdueAssetsFor(uint tradeId) external {}

    function withdrawOverdueAssetSingle(uint tradeId) external {}
}