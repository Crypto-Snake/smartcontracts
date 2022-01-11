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
    }

    event UpdateEggPrice(uint id, uint oldPrice, uint newPrice, uint period, uint timestamp);

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

        function updateEggPrice(uint typeId, uint price) external onlyOwner {
        _updateEggPrice(typeId, price);
    }

    function updateEggPrices(uint[] memory types, uint[] memory prices) external onlyOwner {
        require(types.length == prices.length, "NFTPropertiesManager: types and prices array length missmatch");

        for(uint i = 0; i < prices.length; i++) {
            _updateEggPrice(types[i], prices[i]);
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

    function _updateEggPrice(uint typeId, uint price) internal {
        require(price != 0, "NFTPropertiesManager: price can not be equal to zero");
        uint oldPrice = eggsProperties[typeId].Price;
        uint period = ++_lastPeriodIdBySnakeType[typeId];
        _periodTimestampBySnakeTypeAndPeriodId[typeId][period] = block.timestamp;
        _periodPriceBySnakeTypeAndPeriodId[typeId][period] = price;
        emit UpdateEggPrice(typeId, oldPrice, price, period, block.timestamp);
    }
}