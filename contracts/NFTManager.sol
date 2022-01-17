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
        _setTarget(this.isStakeAmountGraterThanRequired.selector, _target);
        _setTarget(this.isUserBlocked.selector, _target);
    }

    function hatchEgg(uint tokenId) external onlyEggOwner(tokenId) {
        require(isEggReadyForHatch(tokenId), "NFTManager: Snake is not ready for hatching");
        require(snakes[tokenId].HatchingTime == 0, "NFTManager: Snake with provided id already exists");
        require(!isUserBlocked(msg.sender), "NFTManager: User is blocked");

        EggStats memory stats = eggs[tokenId];

        snakeEggsNFT.safeBurn(tokenId);
        snakesNFT.safeMint(msg.sender, tokenId);        

        uint rate = stats.SnakeType == 5 ? blackMambaBaseRate() : baseRate;

        stakingPool.stakeFor(stats.PurchasingAmount, tokenId, rate, false);
        
        snakes[tokenId] = SnakeStats(tokenId, stats.SnakeType, block.timestamp, rate, 0, stats.PurchasingAmount, 0, 0, 0, 0, 0, 1, false, 0);
        
        snakeAppliedArtifacts[tokenId] = SnakeAppliedArtifacts(0, 0, 0, 0, 0, 0, false, false, false, 0);
        emit HatchEgg(tokenId);
    }

    function feedSnake(uint snakeId, address token, uint amount) external onlySnakeOwner(snakeId) {
        SnakeStats memory stats = snakes[snakeId];
        require(amount > 0, "NFTManager: Feed amount cannot be lower then 1");
        require(allowedTokens[token], "NFTManager: Not allowed token for feed");
        require(!stats.IsDead, "NFTManager: Snake with provided id is dead");
        require(!isUserBlocked(msg.sender), "NFTManager: User is blocked");
        
        uint snakeEquivalentAmount = getSnakeEquivalentAmount(token, amount);

        TransferHelper.safeTransferFrom(token, msg.sender, custodian, amount);

        snakes[snakeId].StakeAmount += snakeEquivalentAmount;
        snakes[snakeId].PreviousFeededTime = snakes[snakeId].LastFeededTime;
        snakes[snakeId].LastFeededTime = block.timestamp;
        snakes[snakeId].TimesFeeded += 1;

        if(snakeEquivalentAmount > treshold) {
            snakes[snakeId].TimesFeededMoreThanTreshold += 1;
        }

        if(stats.Type != 5) {
            uint rateUpdates = snakes[snakeId].StakeAmount / (getSnakeStartPrice(snakeId) * 10) + 1;

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
        }
        
        uint totalAPR = snakes[snakeId].APR + snakes[snakeId].BonusAPR;

        stakingPool.stakeFor(snakeEquivalentAmount, snakeId, totalAPR, false);
    }
}