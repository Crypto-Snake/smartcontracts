//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "./NFTManagerBase.sol";

contract NFTManagerUpdater is NFTManagerBase {

    function initialize(address _target) external onlyOwner {
        _setTarget(this.updateSleepingTime.selector, _target);
    }

    event UpdateSleepingTime(uint indexed snakeId, uint sleepingTime);

    function updateSleepingTime(uint snakeId, uint sleepingTime) external onlyOwner {
        require(_sleepingStartTime[snakeId] != 0, "NFTManager: Snake is awake");
        _sleepingStartTime[snakeId] = sleepingTime;
        emit UpdateSleepingTime(snakeId, sleepingTime);
    }
}