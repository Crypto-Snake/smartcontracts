//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "./NFTManagerBase.sol";

contract NFTArtifactsManager is NFTManagerBase {

    event ApplyMysteryBoxArtifact(uint indexed snakeId, uint applyingTime, address indexed user);
    event ApplyDiamondArtifact(uint indexed snakeId, uint applyingTime, address indexed user);
    event ApplyBombArtifact(uint indexed snakeId, uint applyingTime, address indexed user);
    event ApplyMouseArtifact(uint indexed snakeId, uint stakeAmountBonus, uint applyingTime, address indexed user);
    event ApplyTrophyArtifact(uint indexed snakeId, uint applyingTime, address indexed user);
    event ApplyRainbowUnicornArtifact(uint indexed snakeId, uint applyingTime, address indexed user);
    event ApplySnakeHunterArtifact(uint indexed snakeId, uint applyingTime, address indexed user);
    event ApplySnakeCharmerArtifact(uint indexed snakeId, uint applyingTime, address indexed user);
    event ApplySnakeTimeArtifact(uint indexed snakeId, uint applyingTime, address indexed user);

    function initialize(address _target) external onlyOwner {
        _setTarget(this.applyArtifact.selector, _target);
        _setTarget(this.claimReward.selector, _target);
        _setTarget(this.getSnakeAppliedArtifacts.selector, _target);
    }

    function applyArtifact(uint snakeId, uint artifactId) external onlySnakeOwner(snakeId) onlyArtifactOwner(artifactId) {
        require(allowedArtifacts[artifactId], "NFTManager: Not allowed to apply");

        if(artifactId == 1) {
            snakeAppliedArtifacts[snakeId].TimesMysteryBoxApplied += 1;
            emit ApplyMysteryBoxArtifact(snakeId, block.timestamp, msg.sender);
        } else if(artifactId == 2) {
            require(snakeAppliedArtifacts[snakeId].TimesDiamondApplied < 4, "Cannot apply diamond more than 4 times for one snake");
            _applyDiamondArtifact(snakeId);
        } else if(artifactId == 3) {
            snakeAppliedArtifacts[snakeId].TimesBombApplied += 1;
            emit ApplyBombArtifact(snakeId, block.timestamp, msg.sender);
        } else if(artifactId == 4) {
            _applyMouseArtifact(snakeId);
        } else if(artifactId == 5) {
            _applyTrophyArtifact(snakeId);
        } else if(artifactId == 6) {
            require(!snakeAppliedArtifacts[snakeId].IsRainbowUnicornApplied, "Cannot apply more than one rainbow unicorn for one snake");
            snakeAppliedArtifacts[snakeId].IsRainbowUnicornApplied = true;
            emit ApplyRainbowUnicornArtifact(snakeId, block.timestamp, msg.sender);
        } else if(artifactId == 7) {
            SnakeStats memory stats = snakes[snakeId];
            uint updateAmount = stats.StakeAmount * (shadowSnakeTVLMultiplier - 1);
            _applyShadowSnakeArtifact(snakeId, updateAmount, shadowSnakeDestroyLockPeriod);
        } else if(artifactId == 8) {
            require(!snakeAppliedArtifacts[snakeId].IsSnakeHunterApplied, "Cannot apply more than one snake hunter for one snake");
            snakeAppliedArtifacts[snakeId].IsSnakeHunterApplied = true;
            emit ApplySnakeHunterArtifact(snakeId, block.timestamp, msg.sender);
        } else if(artifactId == 9) {
            require(!snakeAppliedArtifacts[snakeId].IsSnakeHunterApplied, "Cannot apply snake charmer and snake hunter for one snake");
            require(!snakeAppliedArtifacts[snakeId].IsSnakeCharmerApplied, "Cannot apply more than one snake charmer for one snake");
            snakeAppliedArtifacts[snakeId].IsSnakeCharmerApplied = true;
            emit ApplySnakeCharmerArtifact(snakeId, block.timestamp, msg.sender);
        } else if(artifactId == 10) {
            _applySnakeTimeArtifact(snakeId);
        }

        if(artifactId != 6) {
            artifactsNFT.burn(msg.sender, artifactId, 1);
        }
    }

    function claimReward(uint snakeId, uint artifactId) external onlySnakeOwner(snakeId) {

        if(artifactId == 8) {
            require(snakeAppliedArtifacts[snakeId].IsSnakeHunterApplied, "NFTManager: Snake hunter is not applied");
            require(!snakeAppliedArtifacts[snakeId].IsSnakeCharmerApplied, "NFTManager: Snake charmer is already applied");
            stakingPool.getRewardFor(snakeId, msg.sender, false, 8);
        } else if (artifactId == 9) {
            require(snakeAppliedArtifacts[snakeId].IsSnakeCharmerApplied, "NFTManager: Snake charmer is not applied");
            stakingPool.getRewardFor(snakeId, msg.sender, true, 9);
        }
    }
    
    function getSnakeAppliedArtifacts(uint snakeId) external view returns (SnakeAppliedArtifacts memory) {
        require(snakes[snakeId].HatchingTime != 0, "NFTManager: Snake with provided id does not exists");
        return snakeAppliedArtifacts[snakeId];
    }
    
    function _applyDiamondArtifact(uint snakeId) internal {
        _updateBonusStakeRate(snakeId, diamondAPRBonus, true);
        snakeAppliedArtifacts[snakeId].TimesDiamondApplied += 1;
        emit ApplyDiamondArtifact(snakeId, block.timestamp, msg.sender);
    }

    function _applyMouseArtifact(uint snakeId) internal {
        uint updateAmount = (snakes[snakeId].StakeAmount * mouseTVLBonus) / percentPrecision;
        _updateStakeAmount(snakeId, updateAmount, true, 4);
        snakeAppliedArtifacts[snakeId].TimesMouseApplied += 1;
        emit ApplyMouseArtifact(snakeId, updateAmount, block.timestamp, msg.sender);
    }

    function _applySnakeTimeArtifact(uint snakeId) internal {
        stakingPool.getRewardFor(snakeId, msg.sender, false, 10);
        snakeAppliedArtifacts[snakeId].TimesSnakeTimeApplied += 1;
        emit ApplySnakeTimeArtifact(snakeId, block.timestamp, msg.sender);
    }

    function _applyTrophyArtifact(uint snakeId) internal {
        snakeAppliedArtifacts[snakeId].TimesTrophyApplied += 1;
        emit ApplyTrophyArtifact(snakeId, block.timestamp, msg.sender);
    }
}