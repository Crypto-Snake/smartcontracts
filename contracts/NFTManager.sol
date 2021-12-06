//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "./utils/TransferHelper.sol";
import "./NFTManagerBase.sol";

contract NFTManager is NFTManagerBase {

    event HatchEgg(uint indexed tokenId);

    function initialize(address _target) external onlyOwner {
        _setTarget(this.hatchEgg.selector, _target);
        _setTarget(this.feedSnake.selector, _target);
        
        _setTarget(this.destroySnake.selector, _target);
        _setTarget(this.updateAllowedTokens.selector, _target);
        _setTarget(this.updateLowerAdmin.selector, _target);
        _setTarget(this.updateAllowedArtifacts.selector, _target);
        _setTarget(this.updateSnakeEggsShop.selector, _target);
        _setTarget(this.updateStakingPool.selector, _target);
        _setTarget(this.updateSnakeEggsNFT.selector, _target);
        _setTarget(this.updateSnakesNFT.selector, _target);
        _setTarget(this.updateArtifactsNFT.selector, _target);
        _setTarget(this.updateTreshold.selector, _target);
        _setTarget(this.updateBaseRate.selector, _target);
        _setTarget(this.updateBonusFeedRate.selector, _target);
        _setTarget(this.updateMaxRate.selector, _target);
        _setTarget(this.updateCustodian.selector, _target);
        _setTarget(this.updateDiamondAPRBonus.selector, _target);
        _setTarget(this.updateMouseTVLBonus.selector, _target);
        _setTarget(this.updateShadowSnakeRequiredTVL.selector, _target);
        _setTarget(this.updateDiamondMaxAppliances.selector, _target);
        
        _setTarget(this.updateRouter.selector, _target);
        _setTarget(this.updateSnakeToken.selector, _target);
        _setTarget(this.toggleUseWeightedRates.selector, _target);
        _setTarget(this.updateTokenWeightedExchangeRate.selector, _target);
    }

    function hatchEgg(uint tokenId) external onlyEggOwner(tokenId) {
        require(isEggReadyForHatch(tokenId), "NFTManager: Snake is not ready for hatching");
        require(snakes[tokenId].HatchingTime == 0, "NFTManager: Snake with provided id already exists");

        EggStats memory stats = eggs[tokenId];

        snakeEggsNFT.safeBurn(tokenId);
        snakesNFT.safeMint(msg.sender, tokenId);
        
        stakingPool.stakeFor(stats.PurchasingAmount, tokenId, baseRate, false);
        snakes[tokenId] = SnakeStats(tokenId, stats.SnakeType, block.timestamp, baseRate, 0, stats.PurchasingAmount, 0, 0, 0, 0, 0, 1, false, 0);
        snakeAppliedArtifacts[tokenId] = SnakeAppliedArtifacts(0, 0, 0, 0, 0, 0, false, false, false, 0);
        emit HatchEgg(tokenId);
    }

    function feedSnake(uint snakeId, address token, uint amount) external onlySnakeOwner(snakeId) {
        SnakeStats memory stats = snakes[snakeId];
        Egg memory properties = eggsProperties[stats.Type];
        require(amount > 0, "NFTManager: Feed amount cannot be lower then 1");
        require(allowedTokens[token], "NFTManager: Not allowed token for feed");
        require(!stats.IsDead, "NFTManager: Snake with provided id is dead");
        uint snakeEquivalentAmount = getSnakeEquivalentAmount(token, amount);

        TransferHelper.safeTransferFrom(token, msg.sender, custodian, amount);

        snakes[snakeId].StakeAmount += snakeEquivalentAmount;
        snakes[snakeId].PreviousFeededTime = snakes[snakeId].LastFeededTime;
        snakes[snakeId].LastFeededTime = block.timestamp;
        snakes[snakeId].TimesFeeded += 1;

        if(snakeEquivalentAmount > treshold) {
            snakes[snakeId].TimesFeededMoreThanTreshold += 1;
        }

        
        uint rateUpdates = snakes[snakeId].StakeAmount / (properties.Price * 10) + 1;

        if(rateUpdates > 11) {
            rateUpdates = 11;
        }
        
        uint updateTimes = rateUpdates - stats.TimesRateUpdated;

        if(updateTimes > 0 && snakes[snakeId].APR < maxRate) {
            if(stats.TimesRateUpdated == 1) {
                snakes[snakeId].APR += bonusFeedRate;
            } 
            
            snakes[snakeId].APR += (updateTimes * bonusFeedRate);
            snakes[snakeId].TimesRateUpdated = rateUpdates;
        }

        uint totalAPR = snakes[snakeId].APR + snakes[snakeId].BonusAPR;

        stakingPool.stakeFor(snakeEquivalentAmount, snakeId, totalAPR, false);
    }
}