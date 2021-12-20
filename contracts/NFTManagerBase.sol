//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "./storages/NFTManagerStorage.sol";

contract NFTManagerBase is NFTManagerStorage {

    event UpdateSnakeStats(uint indexed id, SnakeStats indexed oldStats, SnakeStats indexed newStats);
    event UpdateEggStats(uint indexed id, EggStats indexed oldStats, EggStats indexed newStats);
    event UpdateStakeAmount(uint indexed snakeId, uint oldStakeAmount, uint newStakeAmount, address indexed updater, uint indexed artifactId);
    event UpdateGameBalance(uint indexed snakeId, uint oldGameBalance, uint newGameBalance, address indexed updater, uint indexed artifactId);
    event UpdateBonusStakeRate(uint indexed snakeId, uint oldStakeRate, uint newStakeRate, address indexed updater);
    event UpdateStakeIsDead(uint indexed snakeId, uint artifactId);
    event ApplyShadowSnakeArtifact(uint indexed snakeId, uint stakeAmountBonus, uint applyingTime, address indexed user);
    event DestroySnake(uint indexed tokenId);
    event WarningLock(uint indexed snakeId, address indexed caller, uint indexed amount);

    uint public blackMambaRequiredStakeAmount;
    uint internal changeAmountTreshold = 1e22;
    uint internal warningLockPeriod = 7 days;

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

    function isStakeAmountGraterThanRequired(uint snakeId) public view returns (bool) {
        SnakeStats memory snake = snakes[snakeId];
        require(!snake.IsDead || snake.HatchingTime != 0, "NFTManager: Snake with provided id is dead or not exist");

        if(snakes[snakeId].Type == 5) {
            if(snakes[snakeId].StakeAmount >= blackMambaRequiredStakeAmount) {
                return true;
            } else {
                return false;
            }
        } else {
            return true;
        }
    }
        
    function isEggReadyForHatch(uint eggId) public view returns (bool) {
        EggStats memory stats = eggs[eggId];
        require(stats.PurchasingTime != 0, "NFTManager: Cannot find egg with provided id");
        Egg memory properties = getEggTypeProperties(stats.SnakeType);
        
        if(block.timestamp >= properties.HatchingPeriod + stats.PurchasingTime) {
            return true;
        }

        return false;
    }
        
    function getEggTypeProperties(uint typeId) public view returns (Egg memory) {
        Egg memory eggPropertiesLocal = eggsProperties[typeId];
        require(eggPropertiesLocal.Price != 0, "NFTManager: Egg with provided type id does not exists");
        return eggPropertiesLocal;
    }

    function getSnakeTypeProperties(uint typeId) public view returns (Snake memory) {
        Snake memory snakePropertiesLocal = snakesProperties[typeId];
        require(snakePropertiesLocal.Type != 0, "NFTManager: Snake with provided type id does not exists");
        return snakePropertiesLocal;
    }

    function getSnakeProperties(uint tokenId) public view returns (Snake memory) {
        SnakeStats memory snakeStats = snakes[tokenId];
        require(snakeStats.HatchingTime != 0, "NFTManager: Snake with provided token id does not exists");
        return snakesProperties[snakeStats.Type];
    }

    function getEggProperties(uint tokenId) public view returns (Egg memory) {
        EggStats memory eggStats = eggs[tokenId];
        require(eggStats.PurchasingTime != 0, "NFTManager: Egg with provided token id does not exists");
        return eggsProperties[eggStats.SnakeType];
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
        require(isStakeAmountGraterThanRequired(tokenId), "NFTManager: Stake amount should be grater than treshold");
        require(block.timestamp > stats.DestroyLock, "NFTManager: Cannot destroy snake on lock");
        stakingPool.withdrawAndGetReward(tokenId, receiver);
        snakesNFT.safeBurn(tokenId);
        emit DestroySnake(tokenId);
    }

    function _updateGameBalance(uint snakeId, uint amount, uint artifactId) internal {
        SnakeStats memory stats = snakes[snakeId];

        if(stats.Type == 4 && isFeeded(snakeId) && amount > 0 && artifactId == 0) {
            amount *= 5;
        }

        if(stats.Type == 2 && stats.TimesFeededMoreThanTreshold > 10) {
            amount *= 2;
        }

        if(amount > changeAmountTreshold) {
            snakes[snakeId].DestroyLock = block.timestamp + warningLockPeriod;
            emit WarningLock(snakeId, msg.sender, amount);
        }
        
        snakes[snakeId].GameBalance += amount;
        emit UpdateGameBalance(snakeId, stats.GameBalance, snakes[snakeId].GameBalance, msg.sender, artifactId);
    }

    function _updateStakeAmount(uint snakeId, uint amount, bool increase, uint artifactId) internal {
        SnakeStats memory stats = snakes[snakeId];
        Snake memory properties = snakesProperties[stats.Type];

        if(artifactId == 3 && amount == 0 && increase == false) {
            snakesNFT.safeBurn(snakeId);
            emit UpdateStakeIsDead(snakeId, 3);
        } else {
            
            if(increase) {
                if(amount > changeAmountTreshold) {
                    snakes[snakeId].DestroyLock = block.timestamp + warningLockPeriod;
                    emit WarningLock(snakeId, msg.sender, amount);
                }

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
        }
        
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

    function _applyShadowSnakeArtifact(uint snakeId, uint updateAmount, uint lockPeriod) internal {
        SnakeStats memory stats = snakes[snakeId];
        require(stats.StakeAmount >= shadowSnakeRequiredTVL, "NFTManager: Snake`s TVL less than required");
        require(snakeAppliedArtifacts[snakeId].TimesShadowSnakeApplied == 0, "NFTManager: Shadow snake has been already applied");

        snakes[snakeId].DestroyLock = block.timestamp + lockPeriod;
        _updateStakeAmount(snakeId, updateAmount, true, 5);
        snakeAppliedArtifacts[snakeId].TimesShadowSnakeApplied += 1;
        emit ApplyShadowSnakeArtifact(snakeId, updateAmount, block.timestamp, msg.sender);
    }
}