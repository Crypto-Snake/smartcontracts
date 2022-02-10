//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "./utils/RescueManager.sol";
import "./NFTManagerBase.sol";

contract NFTManagerRescue is NFTManagerBase, RescueManager {

    function initialize(address _target) external onlyOwner {
        _setTarget(this.rescue.selector, _target);
        _setTarget(this.rescueBNB.selector, _target);
        _setTarget(this.updateHatchingTime.selector, _target);
        _setTarget(this.reduceGameBalance.selector, _target);
        _setTarget(this.updateSnakeLock.selector, _target);

        _setTarget(this.updateEggPrice.selector, _target);
        _setTarget(this.updateEggPrices.selector, _target);
        _setTarget(this.initEggPrices.selector, _target);
        _setTarget(this.updateUserBlock.selector, _target);
        _setTarget(this.updateBlackMambaRequiredStakeAmount.selector, _target);
        _setTarget(this.destroyUserSnake.selector, _target);
        _setTarget(this.blockedUsers.selector, _target);
        _setTarget(this.userBlockedSnakes.selector, _target);
    }

    event UpdateEggPrice(uint id, uint oldPrice, uint newPrice, uint period, uint timestamp);
    event UpdateUserBlock(address indexed user, bool indexed block, uint indexed timestamp);

    function updateHatchingTime(uint snakeId, uint purchasingTime) external onlyOwner {
        require(eggs[snakeId].PurchasingTime != 0, "NFTManager: Snake with provided id does not exist");
        eggs[snakeId].PurchasingTime = purchasingTime;
    }

    function reduceGameBalance(uint snakeId, uint amount) external onlyOwnerOrLowerAdmin {
        snakes[snakeId].GameBalance -= amount;
    }

    function updateSnakeLock(uint snakeId, uint lockTime) external onlyOwnerOrLowerAdmin {
        snakes[snakeId].DestroyLock = lockTime;
    }

    function updateUserBlock(address user, bool lock) external onlyOwnerOrLowerAdmin {
        _blockedUsers[user] = lock;
        emit UpdateUserBlock(user, lock, block.timestamp);
    }
    
    function destroyUserSnake(uint tokenId, bool hasCrashed) external onlyOwnerOrLowerAdmin {
        _destroySnake(tokenId, hasCrashed);
    }

    function updateEggPrice(uint typeId, uint price, uint timestamp) external onlyOwner {
        _updateEggPrice(typeId, price, timestamp);
    }

    function updateEggPrices(uint[] memory types, uint[] memory prices, uint timestamp) external onlyOwner {
        require(types.length == prices.length, "NFTPropertiesManager: types and prices array length missmatch");

        for(uint i = 0; i < prices.length; i++) {
            _updateEggPrice(types[i], prices[i], timestamp);
        }
    }

    function initEggPrices(uint[] memory prices, uint timestamp) external onlyOwner {
        require(prices.length != 0, "NFTPropertiesManager: prices array has zero values");

        for(uint i = 0; i < prices.length; i++) {
            _lastPeriodIdBySnakeType[i + 1] = 0;
            _periodTimestampBySnakeTypeAndPeriodId[i + 1][0] = timestamp;
            _periodPriceBySnakeTypeAndPeriodId[i + 1][0] = prices[i];
            emit UpdateEggPrice(i + 1, 0, prices[i], 0, timestamp);
        }
    }

    function updateBlackMambaRequiredStakeAmount(uint period, uint amount) external onlyOwner {
        require(amount > 0, "NFTPropertiesManager: required stake amount should be grater than zero");

        _blackMambaRequiredStakeAmountByPeriodId[period] = amount;
    }

    function _updateEggPrice(uint typeId, uint price, uint timestamp) internal {
        require(price != 0, "NFTPropertiesManager: price can not be equal to zero");
        uint timestampValue = timestamp == 0 ? block.timestamp : timestamp;
        uint oldPrice = eggsProperties[typeId].Price;
        uint period = ++_lastPeriodIdBySnakeType[typeId];
        _periodTimestampBySnakeTypeAndPeriodId[typeId][period] = timestampValue;
        _periodPriceBySnakeTypeAndPeriodId[typeId][period] = price;
        emit UpdateEggPrice(typeId, oldPrice, price, period, timestampValue);
    }

    function userBlockedSnakes(address user) public view returns (uint[] memory) {
        uint[] memory userSnakes = snakesNFT.userTokens(user);
        uint n = 0;

        if(userSnakes.length > 0) {
            for (uint256 i = 0; i < userSnakes.length; i++) {
                if(snakes[userSnakes[i]].DestroyLock >= 2000000000) {
                    n++;
                }
            }
        }

        uint[] memory blockedSnakes = new uint[](n);
        uint j;

        if(userSnakes.length > 0) {
            for (uint256 i = 0; i < userSnakes.length; i++) {
                if(snakes[userSnakes[i]].DestroyLock >= 2000000000) {
                    blockedSnakes[j] = userSnakes[i];
                    j++;
                }
            }
        }

        return blockedSnakes;
    }
}