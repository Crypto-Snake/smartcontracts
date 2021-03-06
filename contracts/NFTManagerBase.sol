//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "./storages/NFTManagerStorage.sol";

contract NFTManagerBase is NFTManagerStorage {

    event UpdateSnakeProperties(uint id, Snake oldProperties, Snake newProperties);
    event UpdateEggProperties(uint id, Egg oldProperties, Egg newProperties);
    event UpdateArtifactProperties(uint id, Artifact oldProperties, Artifact newProperties);
    event UpdateSnakeStats(uint indexed id, SnakeStats indexed oldStats, SnakeStats indexed newStats);
    event UpdateEggStats(uint indexed id, EggStats indexed oldStats, EggStats indexed newStats);
    event UpdateStakeAmount(uint indexed snakeId, uint oldStakeAmount, uint newStakeAmount, address indexed updater, uint indexed artifactId);
    event UpdateGameBalance(uint indexed snakeId, uint oldGameBalance, uint newGameBalance, address indexed updater, uint indexed artifactId);
    event UpdateBonusStakeRate(uint indexed snakeId, uint oldStakeRate, uint newStakeRate, address indexed updater);
    event UpdateStakeIsDead(uint indexed snakeId, uint artifactId);
    event DestroySnake(uint indexed tokenId);

    modifier onlySnakeEggsShop() {
        require(msg.sender == snakeEggsShop, "NFTManager: Caller is not a snake eggs shop contract");
        _;
    }

    modifier onlyEggOwner(uint eggId) {
        require(snakeEggsNFT.ownerOf(eggId) == msg.sender, "NFTManager: Caller is not an owner of a egg");
        _;
    }

    modifier onlySnakeOwner(uint snakeId) {
        require(snakesNFT.ownerOf(snakeId) == msg.sender, "NFTManager: Caller is not an owner of a snake");
        _;
    }

    modifier onlyArtifactOwner(uint artifactId) {
        require(artifactsNFT.balanceOf(msg.sender, artifactId) > 0, "NFTManager: Caller is not an owner of an artifact");
        _;
    }

    function isFeeded(uint snakeId) public view returns (bool) {
        SnakeStats memory stats = snakes[snakeId];

        if(stats.LastFeededTime > block.timestamp - 86400 && stats.PreviousFeededTime > block.timestamp - 86400) {
            return true;
        }
        
        return false;
    }

    function canApplyArtifact(uint snakeId, uint artifactId) external view returns (bool canApply) {
        if(artifactId == 2) {
            return snakeAppliedArtifacts[snakeId].TimesDiamondApplied <= 4 ? true : false;
        } else if(artifactId == 7) {
            return !snakeAppliedArtifacts[snakeId].IsRainbowUnicornApplied ? true : false;
        } else if(artifactId == 8) {
            return !snakeAppliedArtifacts[snakeId].IsSnakeHunterApplied ? true : false;
        } else if(artifactId == 9) {
            return !snakeAppliedArtifacts[snakeId].IsSnakeCharmerApplied ? true : false;
        }
    }
        
    function isEggReadyForHatch(uint eggId) public view returns (bool) {
        EggStats memory stats = eggs[eggId];
        require(stats.PurchasingTime != 0, "NFTManager: Cannot find egg with provided id");
        Egg memory properties = getEggProperties(stats.SnakeType);
        
        if(block.timestamp >= properties.HatchingPeriod + stats.PurchasingTime) {
            return true;
        }

        return false;
    }
        
    function getEggProperties(uint id) public view returns (Egg memory) {
        Egg memory eggPropertiesLocal = eggsProperties[id];
        require(eggPropertiesLocal.Price != 0, "NFTManager: Egg with provided id does not exists");
        return eggPropertiesLocal;
    }

    function getSnakeProperties(uint id) public view returns (Snake memory) {
        Snake memory snakePropertiesLocal = snakesProperties[id];
        require(snakePropertiesLocal.Type != 0, "NFTManager: Snake with provided id does not exists");
        return snakePropertiesLocal;
    }

    function getEggStats(uint tokenId) public view returns (EggStats memory) {
        EggStats memory eggStatsLocal = eggs[tokenId];
        require(eggStatsLocal.PurchasingTime != 0, "NFTManager: Egg with provided id does not exists");
        return eggStatsLocal;
    }

    function getSnakeStats(uint tokenId) public view returns (SnakeStats memory) {
        SnakeStats memory snakeStatsLocal = snakes[tokenId];
        require(snakeStatsLocal.HatchingTime != 0, "NFTManager: Snake with provided id does not exists");
        return snakeStatsLocal;
    }

    function destroySnake(uint256 tokenId) public onlySnakeOwner(tokenId) {
        address receiver = snakesNFT.ownerOf(tokenId);
        SnakeStats memory stats = snakes[tokenId];
        require(block.timestamp > stats.DestroyLock, "NFTManager: Cannot destroy snake on lock");
        stakingPool.withdrawAndGetReward(tokenId, receiver);
        snakesNFT.safeBurn(tokenId);
        emit DestroySnake(tokenId);
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

    function _updateGameBalance(uint snakeId, uint amount, uint artifactId) internal {
        SnakeStats memory stats = snakes[snakeId];

        if(stats.Type == 4 && isFeeded(snakeId) && amount > 0 && artifactId == 0) {
            amount *= 5;
        }
        
        snakes[snakeId].GameBalance += amount;
        emit UpdateGameBalance(snakeId, stats.GameBalance, snakes[snakeId].GameBalance, msg.sender, artifactId);
    }

    function _updateStakeAmount(uint snakeId, uint amount, bool increase, uint artifactId) internal {
        SnakeStats memory stats = snakes[snakeId];
        Snake memory properties = snakesProperties[stats.Type];

        if(increase) {
            snakes[snakeId].StakeAmount += amount;
        } else {
            require(stats.StakeAmount> amount, "NFTManager: Snake`s stake amount lower then update amount");
            snakes[snakeId].StakeAmount -= amount;

            if(snakes[snakeId].StakeAmount < properties.DeathPoint) {
                destroySnake(snakeId);
                snakes[snakeId].IsDead = true;
                emit UpdateStakeIsDead(snakeId, 0);
                return;
            }
        }

        stakingPool.updateAmountForStake(snakeId, amount, increase);
        emit UpdateStakeAmount(snakeId, stats.StakeAmount, snakes[snakeId].StakeAmount, msg.sender, artifactId);
    }

    function _updateBonusStakeRate(uint snakeId, uint rate, bool increase) internal {
        uint previousStakeRate = snakes[snakeId].APR;
        if(increase) {
            snakes[snakeId].BonusAPR += rate;
        } else {
            require(previousStakeRate > rate, "NFTManager: Snake`s stake rate lower then update rate");
            snakes[snakeId].BonusAPR -= rate;
        }

        emit UpdateBonusStakeRate(snakeId, previousStakeRate, snakes[snakeId].BonusAPR, msg.sender);
    }
}