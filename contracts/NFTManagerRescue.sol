//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "./utils/RescueManager.sol";
import "./storages/NFTManagerStorage.sol";

contract NFTManagerRescue is NFTManagerStorage, RescueManager {

    function initialize(address _target) external onlyOwner {
        _setTarget(this.rescue.selector, _target);
        _setTarget(this.rescueBNB.selector, _target);
        _setTarget(this.updateHatchingTime.selector, _target);
        _setTarget(this.reduceGameBalance.selector, _target);
        _setTarget(this.updateSnakeLock.selector, _target);
    }

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
}