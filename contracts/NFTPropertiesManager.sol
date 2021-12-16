//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "./NFTManagerBase.sol";

contract NFTPropertiesManager is NFTManagerBase {

    function initialize(address _target) external onlyOwner {
        _setTarget(this.updateSnakeProperties.selector, _target);
        _setTarget(this.updateEggProperties.selector, _target);
        _setTarget(this.updateArtifactProperties.selector, _target);
        _setTarget(this.updateMambaRequiredStakeAmount.selector, _target);

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
        _setTarget(this.updateRouter.selector, _target);
        _setTarget(this.updateSnakeToken.selector, _target);
        _setTarget(this.toggleUseWeightedRates.selector, _target);
        _setTarget(this.updateTokenWeightedExchangeRate.selector, _target);
    }

    event UpdateSnakeProperties(uint id, Snake oldProperties, Snake newProperties);
    event UpdateEggProperties(uint id, Egg oldProperties, Egg newProperties);
    event UpdateArtifactProperties(uint id, Artifact oldProperties, Artifact newProperties);
    event UpdateBlackMambaRequiredStakeAmount(uint indexed requiredStakeAmount);
    
    event UpdateStakingPool(address indexed _stakingPool);
    event UpdateSnakeEggsShop(address indexed _snakeEggsShop);
    event UpdateSnakesNFT(address indexed _snakesNFT);
    event UpdateSnakeEggsNFT(address indexed _snakeEggsNFT);
    event UpdateArtifactsNFT(address indexed _artifactsNFT);
    event UpdateAllowedAddresses(address indexed value, bool indexed allowance);
    event UpdateAllowedTokens(address indexed token, bool indexed allowance);
    event UpdateAllowedArtifacts(uint indexed artifactId, bool indexed allowance);
    event UpdateCustodian(address indexed newCustodian);
    event UpdateDiamondAPRBonus(uint aprBonus);
    event UpdateMouseTVLBonus(uint tvlBonus);
    event UpdateShadowSnakeRequiredTVL(uint requiredTVL);
    event UpdateShadowSnakeDestroyLockPeriod(uint lockPeriod);
    event UpdateShadowSnakeTVLMultiplier(uint tvlMultiplier);
    event UpdateDiamondMaxAppliances(uint maxAppilances);
    event UpdateTreshold(uint treshold);
    event UpdateBaseRate(uint baseRate);
    event UpdateBonusFeedRate(uint bonusRate);
    event UpdateMaxRate(uint maxRate);

    function updateAllowedTokens(address token, bool allowance) external onlyOwner {
        allowedTokens[token] = allowance;
        emit UpdateAllowedTokens(token, allowance);
    }

    function updateAllowedArtifacts(uint artifactId, bool allowance) external onlyOwner {
        allowedArtifacts[artifactId] = allowance;
        emit UpdateAllowedArtifacts(artifactId, allowance);
    }

    function updateSnakeEggsShop(address _snakeEggsShop) external onlyOwner {
        require(Address.isContract(_snakeEggsShop), "NFTManager: _snakeEggsShop is not a contract");
        snakeEggsShop = _snakeEggsShop;
        emit UpdateSnakeEggsShop(_snakeEggsShop);
    }
        
    function updateStakingPool(address _stakingPool) external onlyOwner {
        require(Address.isContract(_stakingPool), "NFTManager: _stakingPool is not a contract");
        stakingPool = ILockStakingRewardsPool(_stakingPool);
        emit UpdateStakingPool(_stakingPool);
    }
    
    function updateSnakeEggsNFT(address _snakeEggsNFT) external onlyOwner {
        require(Address.isContract(_snakeEggsNFT), "NFTManager: _snakeEggsNFT is not a contract");
        snakeEggsNFT = IBEP721Enumerable(_snakeEggsNFT);
        emit UpdateSnakeEggsNFT(_snakeEggsNFT);
    }

    function updateSnakesNFT(address _snakesNFT) external onlyOwner {
        require(Address.isContract(_snakesNFT), "NFTManager: _snakesNFT is not a contract");
        snakesNFT = IBEP721Enumerable(_snakesNFT);
        emit UpdateSnakesNFT(_snakesNFT);
    }

    function updateArtifactsNFT(address _artifactsNFT) external onlyOwner {
        require(Address.isContract(_artifactsNFT), "NFTManager: _artifactsNFT is not a contract");
        artifactsNFT = IBEP1155(_artifactsNFT);
        emit UpdateArtifactsNFT(_artifactsNFT);
    }

    function updateTreshold(uint _treshold) external onlyOwner {
        require(_treshold > 0, "NFTManager: treshold must be grater than 0");
        treshold = _treshold;
        emit UpdateTreshold(_treshold);
    }

    function updateBaseRate(uint _baseRate) external onlyOwner {
        require(_baseRate > 0, "NFTManager: base rate must be grater than 0");
        baseRate = _baseRate;
        emit UpdateBaseRate(_baseRate);
    }

    function updateBonusFeedRate(uint _bonusFeedRate) external onlyOwner {
        require(_bonusFeedRate > 0, "NFTManager: bonus rate must be grater than 0");
        bonusFeedRate = _bonusFeedRate;
        emit UpdateBonusFeedRate(_bonusFeedRate);
    }

    function updateMaxRate(uint _maxRate) external onlyOwner {
        require(_maxRate > 0, "NFTManager: max rate must be grater than 0");
        maxRate = _maxRate;
        emit UpdateMaxRate(_maxRate);
    }

    function updateCustodian(address newCustodian) external onlyOwner {
        require(newCustodian != address(0), "NFTManager: newCustodian can't be zero address");
        custodian = newCustodian;
        emit UpdateCustodian(newCustodian);
    }

    function updateDiamondAPRBonus(uint aprBonus) external onlyOwner {
        require(aprBonus > 0, "NFTManager: APR bonus must be grater than 0");
        diamondAPRBonus = aprBonus;
        emit UpdateDiamondAPRBonus(aprBonus);
    }

    function updateMouseTVLBonus(uint tvlBonus) external onlyOwner {
        require(tvlBonus > 0, "NFTManager: TVL bonus must be grater than 0");
        mouseTVLBonus = tvlBonus;
        emit UpdateMouseTVLBonus(tvlBonus);
    }

    function updateSnakeProperties(uint id, Snake memory properties) external onlyAllowedAddresses() {
        snakesProperties[id] = properties;
        emit UpdateSnakeProperties(id, snakesProperties[id], properties);
    }

    function updateEggProperties(uint id, Egg memory properties) external onlyAllowedAddresses() {
        eggsProperties[id] = properties;
        emit UpdateEggProperties(id, eggsProperties[id], properties);
    }

    function updateArtifactProperties(uint id, Artifact memory properties) external onlyAllowedAddresses() {
        artifactsProperties[id] = properties;
        emit UpdateArtifactProperties(id, artifactsProperties[id], properties);
    }

    function updateMambaRequiredStakeAmount(uint requiredStakeAmount) external onlyOwner() {
        require(requiredStakeAmount != 0, "NFTManagerBase: requiredStakeAmount can't be equal to 0");
        blackMambaRequiredStakeAmount = requiredStakeAmount;
    }
}