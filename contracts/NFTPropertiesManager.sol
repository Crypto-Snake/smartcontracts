//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "./NFTManagerBase.sol";

contract NFTPropertiesManager is NFTManagerBase {

    function initialize(address _target) external onlyOwner {
        _setTarget(this.updateSnakeProperties.selector, _target);
        _setTarget(this.updateEggProperties.selector, _target);
        _setTarget(this.updateArtifactProperties.selector, _target);
        _setTarget(this.updateBlackMambaBaseRate.selector, _target);
        _setTarget(this.updateChangeAmountTreshold.selector, _target);
        _setTarget(this.updateWarningLockPeriod.selector, _target);

        _setTarget(this.changeAmountTreshold.selector, _target);
        _setTarget(this.warningLockPeriod.selector, _target);
        _setTarget(this.blackMambaBaseRate.selector, _target);
        _setTarget(this.halvingDate.selector, _target);

        _setTarget(this.deathPointPercent.selector, _target);
        _setTarget(this.blackMambaDeathPointPercent.selector, _target);
        _setTarget(this.sleepingTime.selector, _target);

        _setTarget(this.getSnakeStartPrice.selector, _target);
        _setTarget(this.getSnakeDeathPoint.selector, _target);
        _setTarget(this.getCurrentPriceBySnakeType.selector, _target);
        _setTarget(this.getBlackMambaRequiredStakeAmount.selector, _target);

        _setTarget(this.getLastPeriodNumberBySnakeType.selector, _target);
        _setTarget(this.getSnakePriceBySnakeTypeAndPeriodId.selector, _target);
        _setTarget(this.getPeriodTimestampBySnakeTypeAndPeriodId.selector, _target);
        _setTarget(this.getBlackMambaRequiredStakeAmountByPeriodId.selector, _target);

        _setTarget(this.updateAllowedTokens.selector, _target);
        _setTarget(this.updateAllowedAddresses.selector, _target);
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
        _setTarget(this.toggleUseWeightedRates.selector, _target);
        _setTarget(this.updateTokenWeightedExchangeRate.selector, _target);
        _setTarget(this.updateDeathPointPercent.selector, _target);
        _setTarget(this.updateBlackMambaDeathPointPercent.selector, _target);
        _setTarget(this.updateHalvingDate.selector, _target);
        _setTarget(this.updateSleepingTime.selector, _target);
    }

    event UpdateSnakeProperties(uint id, Snake oldProperties, Snake newProperties);
    event UpdateEggProperties(uint id, Egg oldProperties, Egg newProperties);
    event UpdateArtifactProperties(uint id, Artifact oldProperties, Artifact newProperties);
    event UpdateBlackMambaBaseRate(uint indexed rate);
    event UpdateChangeAmountTreshold(uint indexed treshold);
    event UpdateWarningLockPeriod(uint indexed period);
    
    event UpdateStakingPool(address indexed _stakingPool);
    event UpdateSnakeEggsShop(address indexed _snakeEggsShop);
    event UpdateSnakesNFT(address indexed _snakesNFT);
    event UpdateSnakeEggsNFT(address indexed _snakeEggsNFT);
    event UpdateArtifactsNFT(address indexed _artifactsNFT);
    event UpdateAllowedTokens(address indexed token, bool indexed allowance);
    event UpdateAllowedArtifacts(uint indexed artifactId, bool indexed allowance);
    event UpdateCustodian(address indexed newCustodian);
    event UpdateTreshold(uint treshold);
    event UpdateBaseRate(uint baseRate);
    event UpdateBonusFeedRate(uint bonusRate);
    event UpdateMaxRate(uint maxRate);
    event UpdateHalvingDate(uint indexed halvingDate);
    event UpdateSleepingTime(uint indexed sleepingTime);

    function updateAllowedTokens(address token, bool allowance) external onlyOwner {
        allowedTokens[token] = allowance;
        emit UpdateAllowedTokens(token, allowance);
    }

    function updateAllowedArtifacts(uint artifactId, bool allowance) external onlyOwner {
        allowedArtifacts[artifactId] = allowance;
        emit UpdateAllowedArtifacts(artifactId, allowance);
    }

    function updateSnakeEggsShop(address _snakeEggsShop) external onlyOwner {
        require(Address.isContract(_snakeEggsShop), "NFTPropertiesManager: _snakeEggsShop is not a contract");
        snakeEggsShop = _snakeEggsShop;
        emit UpdateSnakeEggsShop(_snakeEggsShop);
    }
        
    function updateStakingPool(address _stakingPool) external onlyOwner {
        require(Address.isContract(_stakingPool), "NFTPropertiesManager: _stakingPool is not a contract");
        stakingPool = ILockStakingRewardsPool(_stakingPool);
        emit UpdateStakingPool(_stakingPool);
    }
    
    function updateSnakeEggsNFT(address _snakeEggsNFT) external onlyOwner {
        require(Address.isContract(_snakeEggsNFT), "NFTPropertiesManager: _snakeEggsNFT is not a contract");
        snakeEggsNFT = IBEP721Enumerable(_snakeEggsNFT);
        emit UpdateSnakeEggsNFT(_snakeEggsNFT);
    }

    function updateSnakesNFT(address _snakesNFT) external onlyOwner {
        require(Address.isContract(_snakesNFT), "NFTPropertiesManager: _snakesNFT is not a contract");
        snakesNFT = IBEP721Enumerable(_snakesNFT);
        emit UpdateSnakesNFT(_snakesNFT);
    }

    function updateArtifactsNFT(address _artifactsNFT) external onlyOwner {
        require(Address.isContract(_artifactsNFT), "NFTPropertiesManager: _artifactsNFT is not a contract");
        artifactsNFT = IBEP1155(_artifactsNFT);
        emit UpdateArtifactsNFT(_artifactsNFT);
    }

    function updateTreshold(uint _treshold) external onlyOwner {
        require(_treshold > 0, "NFTPropertiesManager: treshold must be grater than 0");
        treshold = _treshold;
        emit UpdateTreshold(_treshold);
    }

    function updateBaseRate(uint _baseRate) external onlyOwner {
        require(_baseRate > 0, "NFTPropertiesManager: base rate must be grater than 0");
        baseRate = _baseRate;
        emit UpdateBaseRate(_baseRate);
    }

    function updateBonusFeedRate(uint _bonusFeedRate) external onlyOwner {
        require(_bonusFeedRate > 0, "NFTPropertiesManager: bonus rate must be grater than 0");
        bonusFeedRate = _bonusFeedRate;
        emit UpdateBonusFeedRate(_bonusFeedRate);
    }

    function updateMaxRate(uint _maxRate) external onlyOwner {
        require(_maxRate > 0, "NFTPropertiesManager: max rate must be grater than 0");
        maxRate = _maxRate;
        emit UpdateMaxRate(_maxRate);
    }

    function updateCustodian(address newCustodian) external onlyOwner {
        require(newCustodian != address(0), "NFTPropertiesManager: newCustodian can not be zero address");
        custodian = newCustodian;
        emit UpdateCustodian(newCustodian);
    }

    function updateHalvingDate(uint halvingDate) external onlyOwner {
        _halvingDate = halvingDate;
        emit UpdateHalvingDate(halvingDate);
    }

    function updateSleepingTime(uint sleepingTime) external onlyOwner {
        _sleepingTime = sleepingTime;
        emit UpdateSleepingTime(sleepingTime);
    }

    function updateSnakeProperties(uint typeId, Snake memory properties) external onlyAllowedAddresses {
        Snake memory oldProperties = snakesProperties[typeId];
        snakesProperties[typeId] = properties;
        emit UpdateSnakeProperties(typeId, oldProperties, properties);
    }

    function updateEggProperties(uint typeId, Egg memory properties) external onlyAllowedAddresses {
        Egg memory oldProperties = eggsProperties[typeId];
        eggsProperties[typeId] = properties;
        emit UpdateEggProperties(typeId, oldProperties, properties);
    }

    function updateArtifactProperties(uint id, Artifact memory properties) external onlyAllowedAddresses() {
        artifactsProperties[id] = properties;
        emit UpdateArtifactProperties(id, artifactsProperties[id], properties);
    }

    function updateChangeAmountTreshold(uint treshold) external onlyOwner() {
        require(treshold != 0, "NFTPropertiesManager: treshold can not be equal to 0");
        _changeAmountTreshold = treshold;
        emit UpdateChangeAmountTreshold(treshold);
    }

    function updateWarningLockPeriod(uint period) external onlyOwner() {
        require(period != 0, "NFTPropertiesManager: period can not be equal to 0");
        _warningLockPeriod = period;
        emit UpdateWarningLockPeriod(period);
    }

    function updateBlackMambaBaseRate(uint rate) external onlyOwner() {
        require(rate > 0, "NFTPropertiesManager: rate must be grater than 0");
        _blackMambaBaseRate = rate;
        emit UpdateBlackMambaBaseRate(rate);
    }

    function updateDeathPointPercent(uint percent) external onlyOwner() {
        _deathPointPercent = percent;
    }

    function updateBlackMambaDeathPointPercent(uint percent) external onlyOwner() {
        _blackMambaDeathPointPercent = percent;
    }
}