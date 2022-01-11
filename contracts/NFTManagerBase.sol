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

    uint internal _blackMambaRequiredStakeAmount = 2201e18;
    uint internal _changeAmountTreshold = 1e22;
    uint internal _warningLockPeriod = 7 days;
    uint internal _blackMambaBaseRate = 3e17; // 30%
    uint internal _deathPointPercent = 1e16; // 1%
    uint internal _blackMambaDeathPointPercent = 5e16; // 5%
    mapping(uint => uint) internal _lastPeriodIdBySnakeType;
    mapping(uint => mapping(uint => uint)) internal _periodTimestampBySnakeTypeAndPeriodId;
    mapping(uint => mapping(uint => uint)) internal _periodPriceBySnakeTypeAndPeriodId;
    mapping(uint => uint) internal _blackMambaRequiredStakeAmountByPeriodId;

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

    function getLastPeriodNumberBySnakeType(uint typeId) public view returns (uint) {
        return _lastPeriodIdBySnakeType[typeId];
    }

    function getSnakePriceBySnakeTypeAndPeriodId(uint typeId, uint period) public view returns (uint) {
        return _periodPriceBySnakeTypeAndPeriodId[typeId][period];
    }

    function getPeriodTimestampBySnakeTypeAndPeriodId(uint typeId, uint period) public view returns (uint) {
        return _periodTimestampBySnakeTypeAndPeriodId[typeId][period];
    }

    function getBlackMambaRequiredStakeAmountByPeriodId(uint period) public view returns (uint) {
        return _blackMambaRequiredStakeAmountByPeriodId[period];
    }

    function changeAmountTreshold() public view returns (uint) {
        return _changeAmountTreshold;
    }

    function warningLockPeriod() public view returns (uint) {
        return _warningLockPeriod;
    }

    function blackMambaBaseRate() public view returns (uint) {
        return _blackMambaBaseRate;
    }

    function deathPointPercent() public view returns (uint) {
        return _deathPointPercent;
    }

    function blackMambaDeathPointPercent() public view returns (uint) {
        return _blackMambaDeathPointPercent;
    }

    function isFeeded(uint snakeId) public view returns (bool) {
        SnakeStats memory stats = snakes[snakeId];

        if(stats.LastFeededTime > block.timestamp - 86400 && stats.PreviousFeededTime > block.timestamp - 86400) {
            return true;
        }
        
        return false;
    }

    function getBlackMambaRequiredStakeAmount(uint snakeId) public view returns (uint requiredStakeAmount) {
        EggStats memory egg = eggs[snakeId];
        require(egg.SnakeType == 5, "NFTManager: Snake with provided id is not a Black Mamba");
        require(egg.PurchasingTime != 0, "NFTManager: Snake with provided id is dead or not exist");
        uint lastPeriod = getLastPeriodNumberBySnakeType(egg.SnakeType);

        if(getPeriodTimestampBySnakeTypeAndPeriodId(egg.SnakeType, lastPeriod) < egg.PurchasingTime) {
            requiredStakeAmount = getBlackMambaRequiredStakeAmountByPeriodId(lastPeriod);
        } else {
            for(uint p = lastPeriod; p > 0; p--) {
                if(getPeriodTimestampBySnakeTypeAndPeriodId(egg.SnakeType, p) > egg.PurchasingTime &&
                    getPeriodTimestampBySnakeTypeAndPeriodId(egg.SnakeType, p - 1) < egg.PurchasingTime) {
                        requiredStakeAmount = getBlackMambaRequiredStakeAmountByPeriodId(p - 1);
                        break;
                    }
            }
        }
    }

    function getSnakeStartPrice(uint snakeId) public view returns (uint snakePrice) {
        EggStats memory egg = eggs[snakeId];
        require(egg.PurchasingTime != 0, "NFTManager: Snake with provided id is dead or not exist");
        uint lastPeriod = getLastPeriodNumberBySnakeType(egg.SnakeType);

        if(getPeriodTimestampBySnakeTypeAndPeriodId(egg.SnakeType, lastPeriod) < egg.PurchasingTime) {
            snakePrice = getSnakePriceBySnakeTypeAndPeriodId(egg.SnakeType, lastPeriod);
        } else {
            for(uint p = lastPeriod; p > 0; p--) {
                if(getPeriodTimestampBySnakeTypeAndPeriodId(egg.SnakeType, p) > egg.PurchasingTime &&
                    getPeriodTimestampBySnakeTypeAndPeriodId(egg.SnakeType, p - 1) < egg.PurchasingTime) {
                        snakePrice = getSnakePriceBySnakeTypeAndPeriodId(egg.SnakeType, p - 1);
                        break;
                    }
            }
        }

        require(snakePrice != 0, "NFTManager: Snake price not found");
    }

    function getCurrentPriceBySnakeType(uint typeId) public view returns (uint) {
        uint lastPeriod = getLastPeriodNumberBySnakeType(typeId);
        return getSnakePriceBySnakeTypeAndPeriodId(typeId, lastPeriod);
    }

    function getSnakeDeathPoint(uint snakeId) public view returns (uint) {
        SnakeStats memory snake = snakes[snakeId];
        require(!snake.IsDead || snake.HatchingTime != 0, "NFTManager: Snake with provided id is dead or not exist");

        uint deathPointPersent = snake.Type == 5 ? blackMambaDeathPointPercent() : deathPointPercent();
        return getSnakeStartPrice(snakeId) * deathPointPersent / 1e18;
    }

    function isStakeAmountGraterThanRequired(uint snakeId) public view returns (bool) {
        SnakeStats memory snake = snakes[snakeId];
        require(!snake.IsDead || snake.HatchingTime != 0, "NFTManager: Snake with provided id is dead or not exist");

        if(snakes[snakeId].Type == 5) {
            if(snakes[snakeId].StakeAmount >= getBlackMambaRequiredStakeAmount(snakeId)) {
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
        require(isStakeAmountGraterThanRequired(tokenId), "NFTManager: Stake amount should be grater than treshold");
        _destroySnake(tokenId, false);
    }

    function _updateGameBalance(uint snakeId, uint amount, uint artifactId) internal {
        SnakeStats memory stats = snakes[snakeId];

        if(stats.Type == 4 && isFeeded(snakeId) && amount > 0 && artifactId == 0) {
            amount *= 5;
        }

        if(stats.Type == 2 && stats.TimesFeededMoreThanTreshold > 10) {
            amount *= 2;
        }

        if(amount > changeAmountTreshold()) {
            if(snakes[snakeId].DestroyLock != 0) {
                snakes[snakeId].DestroyLock += warningLockPeriod();
            } else {
                snakes[snakeId].DestroyLock = block.timestamp + warningLockPeriod();
            }
            emit WarningLock(snakeId, msg.sender, amount);
        }
        
        snakes[snakeId].GameBalance += amount;
        emit UpdateGameBalance(snakeId, stats.GameBalance, snakes[snakeId].GameBalance, msg.sender, artifactId);
    }

    function _updateStakeAmount(uint snakeId, uint amount, bool increase, uint artifactId) internal {
        SnakeStats memory stats = snakes[snakeId];

        if(artifactId == 3 && amount == 0 && increase == false) {
            snakesNFT.safeBurn(snakeId);
            emit UpdateStakeIsDead(snakeId, 3);
        } else {
            
            if(increase) {
                snakes[snakeId].StakeAmount += amount;
            } else {
                if(amount >= stats.StakeAmount) {
                    amount = stats.StakeAmount;
                }

                snakes[snakeId].StakeAmount -= amount;

                if(snakes[snakeId].StakeAmount < getSnakeDeathPoint(snakeId)) {
                    stakingPool.updateAmountForStake(snakeId, amount, increase);
                    _destroySnake(snakeId, true);
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

    function _destroySnake(uint256 tokenId, bool hasCrashed) internal {
        address receiver = snakesNFT.ownerOf(tokenId);
        SnakeStats memory stats = snakes[tokenId];
        require(block.timestamp > stats.DestroyLock, "NFTManager: Cannot destroy snake on lock");

        if(!hasCrashed) stakingPool.withdrawAndGetReward(tokenId, receiver);
        snakesNFT.safeBurn(tokenId);
        emit DestroySnake(tokenId);
    }
}