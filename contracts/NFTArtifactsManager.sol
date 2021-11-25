//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "./NFTManagerBase.sol";

contract NFTArtifactsManager is NFTManagerBase {

    event ApplyMisteryBoxArtifact(uint indexed snakeId, uint gameBalanceBonus, uint applyingTime, address indexed user);
    event ApplyBombArtifact(uint indexed snakeId, uint stakeAmountBonus, uint applyingTime, address indexed user);
    event ApplyMouseArtifact(uint indexed snakeId, uint stakeAmountBonus, uint applyingTime, address indexed user);
    event ApplyShadowSnakeArtifact(uint indexed snakeId, uint stakeAmountBonus, uint applyingTime, address indexed user);
    event ApplySnakeTimeArtifact(uint indexed snakeId, uint applyingTime, address indexed user);
    event ApplyTrophyArtifact(uint indexed snakeId, uint applyingTime, address indexed user);
    event ApplyDiamondArtifact(uint indexed snakeId, uint applyingTime, address indexed user);

    function initialize(address _target) external onlyOwner {
        _setTarget(this.applyArtifact.selector, _target);
    }

    function applyArtifactBySign(uint snakeId, uint artifactId, uint updateAmount, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external {
        uint nonce = applyArtifactNonces[msg.sender]++;
        bytes32 digest = keccak256(
            abi.encodePacked(
                '\x19\x01',
                DOMAIN_SEPARATOR,
                keccak256(abi.encode(APPLY_ARTIFACT_TYPEHASH, snakeId, artifactId, updateAmount, nonce, deadline))
            )
        );

        address recoveredAddress = ecrecover(digest, v, r, s);
        require(recoveredAddress != address(0) && recoveredAddress == owner(), 'NFTManager: INVALID_SIGNATURE');
        require(snakesNFT.ownerOf(snakeId) == msg.sender, "NFTManager: Caller is not owner of snake");
        require(artifactsNFT.balanceOf(msg.sender, artifactId) > 0, "NFTManager: Caller is not owner of artifact");

        
        if(artifactId == 1) {
            snakeAppliedArtifacts[snakeId].TimesMysteryBoxApplied += 1;
            _updateGameBalance(snakeId, updateAmount, artifactId);
            emit ApplyMisteryBoxArtifact(snakeId, updateAmount, block.timestamp, msg.sender);
        } else if(artifactId == 3) {

            if(updateAmount != 0) {
                snakes[snakeId].StakeAmount += updateAmount;
                snakeAppliedArtifacts[snakeId].TimesBombApplied += 1;
                _updateStakeAmount(snakeId, updateAmount, true, artifactId);
                emit ApplyBombArtifact(snakeId, updateAmount, block.timestamp, msg.sender);
            } else {
                snakesNFT.safeBurn(snakeId);
                snakes[snakeId].IsDead = true;
                emit ApplyBombArtifact(snakeId, updateAmount, block.timestamp, msg.sender);
                emit UpdateStakeIsDead(snakeId, 3);
                return;
            }
        } 
    }

    function applyArtifact(uint snakeId, uint artifactId) external onlySnakeOwner(snakeId) onlyArtifactOwner(artifactId) {
        require(allowedArtifacts[artifactId], "NFTManager: Not allowed to apply");

        if(artifactId == 2) {
            require(snakeAppliedArtifacts[snakeId].TimesDiamondApplied <= 4, "Cannot apply diamond more times for one snake");
            _applyDiamondArtifact(snakeId);
        } else if(artifactId == 4) {
            _applyMouseArtifact(snakeId);
        } else if(artifactId == 5) {
            _applyShadowSnakeArtifact(snakeId);
        } else if(artifactId == 6) {
            _applyTrophyArtifact(snakeId);
        } else if(artifactId == 7) {
            require(!snakeAppliedArtifacts[snakeId].IsRainbowUnicornApplied, "Cannot apply more than one rainbow unicorn for one snake");
            snakeAppliedArtifacts[snakeId].IsRainbowUnicornApplied = true;
        }else if(artifactId == 8) {
            require(!snakeAppliedArtifacts[snakeId].IsSnakeHunterApplied, "Cannot apply more than one snake hunter for one snake");
            snakeAppliedArtifacts[snakeId].IsSnakeHunterApplied = true;
        } else if(artifactId == 9) {
            require(!snakeAppliedArtifacts[snakeId].IsSnakeCharmerApplied, "Cannot apply more than one snake charmer for one snake");
            snakeAppliedArtifacts[snakeId].IsSnakeCharmerApplied = true;
        } else if(artifactId == 10) {
            _applySnakeTimeArtifact(snakeId);
        }

        if(artifactId != 7) {
            artifactsNFT.burn(msg.sender, artifactId, 1);
        }
    }
    
    function _applyDiamondArtifact(uint snakeId) internal {
        _updateStakeRate(snakeId, diamondAPRBonus, true);
        snakeAppliedArtifacts[snakeId].TimesDiamondApplied += 1;
        emit ApplyDiamondArtifact(snakeId, block.timestamp, msg.sender);
    }

    function _applyMouseArtifact(uint snakeId) internal {
        uint updateAmount = (snakes[snakeId].StakeAmount * mouseTVLBonus) / percentPrecision;
        _updateStakeAmount(snakeId, updateAmount, true, 4);
        snakeAppliedArtifacts[snakeId].TimesMouseApplied += 1;
        emit ApplyMouseArtifact(snakeId, updateAmount, block.timestamp, msg.sender);
    }

    function _applyShadowSnakeArtifact(uint snakeId) internal {
        SnakeStats memory stats = snakes[snakeId];
        require(stats.Type == 1, "NFTManager: Can apply this artifact only to dasypeltis");
        require(stats.StakeAmount >= shadowSnakeRequiredTVL, "NFTManager: Snake`s TVL less than required");

        snakes[snakeId].DestroyLock = block.timestamp + shadowSnakeDestroyLockPeriod;
        uint updateAmount = stats.StakeAmount * (shadowSnakeTVLMultiplier - 1);
        _updateStakeAmount(snakeId, updateAmount, true, 5);
        snakeAppliedArtifacts[snakeId].TimesShadowSnakeApplied += 1;
        emit ApplyShadowSnakeArtifact(snakeId, updateAmount, block.timestamp, msg.sender);
    }

    function _applySnakeTimeArtifact(uint snakeId) internal {
        stakingPool.getRewardFor(snakeId, msg.sender, false);
        snakeAppliedArtifacts[snakeId].TimesSnakeTimeApplied += 1;
        emit ApplySnakeTimeArtifact(snakeId, block.timestamp, msg.sender);
    }

    function _applyTrophyArtifact(uint snakeId) internal {
        snakeAppliedArtifacts[snakeId].TimesTrophyApplied += 1;
        emit ApplyTrophyArtifact(snakeId, block.timestamp, msg.sender);
    }
}