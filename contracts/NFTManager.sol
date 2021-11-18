//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "./utils/TransferHelper.sol";
import "./utils/Convertable.sol";
import "./interfaces/INFTManager.sol";
import "./interfaces/IRouter.sol";
import "./interfaces/IBEP20.sol";
import "./storages/NFTManagerStorage.sol";

contract NFTManager is INFTManager, NFTManagerStorage {

    event UpdateSnakeProprties(uint id, Snake oldProperties, Snake newProperties);
    event UpdateEggProprties(uint id, Egg oldProperties, Egg newProperties);
    event UpdateArtifactProprties(uint id, Artifact oldProperties, Artifact newProperties);
    event UpdateSnakeStats(uint indexed id, SnakeStats indexed oldStats, SnakeStats indexed newStats);
    event UpdateEggStats(uint indexed id, EggStats indexed oldStats, EggStats indexed newStats);
    event HatchEgg(uint indexed tokenId);
    event DestroySnake(uint indexed tokenId);
    event UpdateStakeAmount(uint indexed snakeId, uint oldStakeAmount, uint newStakeAmount, address indexed updater);
    event UpdateGameBalance(uint indexed snakeId, uint oldGameBalance, uint newGameBalance, address indexed updater);
    event UpdateStakeRate(uint indexed snakeId, uint oldStakeRate, uint newStakeRate, address indexed updater);
    event UpdateStakeIsDead(uint snakeId);

    function initialize(address _stakingPool, address _router, address _snakeToken) external initializer {
        require(Address.isContract(_stakingPool), "_stakingPool is not a contract");
        require(Address.isContract(_snakeToken), "_snakeToken is not a contract");
        require(Address.isContract(_router), "_router is not a contract");

        stakingPool = ILockStakingRewardsPool(_stakingPool);
        router = IRouter(_router);
        snakeToken = _snakeToken;

        baseRate = 60 * percentPrecision;
        bonusRate = 5 * percentPrecision;
        maxRate = 110 * percentPrecision;

        uint chainId;
        assembly {
            chainId := chainid()
        }
        
        APPLY_GAME_RESULTS_TYPEHASH = keccak256("ApplyGameResultsBySign(uint snakeId,int stakeAmount,uint gameBalance,uint256 nonce,uint256 deadline)");
        
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256('EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)'),
                keccak256(bytes("NFTManager")),
                keccak256(bytes("1")),
                chainId,
                address(this)
            )
        );
    }

    modifier onlyAllowedAddresses() {
        require(allowedAddresses[msg.sender] || msg.sender == owner(), "NFTManager: Not Caller is not an allowed address");
        _;
    }

    modifier onlySnakeEggsShop() {
        require(msg.sender == snakeEggsShop, "NFTManager: Caller is not a snake eggs shop contract");
        _;
    }

    modifier onlyEggOwner(uint256 tokenId) {
        require(snakeEggsNFT.ownerOf(tokenId) == msg.sender, "NFTManager: Caller is not an owner of a token");
        _;
    }

    modifier onlySnakeOwner(uint256 tokenId) {
        require(snakesNFT.ownerOf(tokenId) == msg.sender, "NFTManager: Caller is not an owner of a token");
        _;
    }

    function applyGameResultsBySign(uint snakeId, int stakeAmount, uint gameBalance, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external {
        uint nonce = nonces[msg.sender]++;
        bytes32 digest = keccak256(
            abi.encodePacked(
                '\x19\x01',
                DOMAIN_SEPARATOR,
                keccak256(abi.encode(APPLY_GAME_RESULTS_TYPEHASH, snakeId, stakeAmount, gameBalance, nonce, deadline))
            )
        );

        address recoveredAddress = ecrecover(digest, v, r, s);
        require(recoveredAddress != address(0) && recoveredAddress == owner(), 'NFTManager: INVALID_SIGNATURE');

        _updateStakeAmount(snakeId, stakeAmount);
        _updateGameBalance(snakeId, gameBalance);
    }
    
    function isEggReadyForHatch(uint eggId) public view returns (bool) {
        EggStats memory stats = getEggStats(eggId);
        require(stats.PurchasingTime != 0, "NFTManager: Cannot find egg with provided id");
        Egg memory properties = getEggProperties(stats.SnakeType);
        
        if(block.timestamp >= properties.HatchingPeriod + stats.PurchasingTime) {
            return true;
        }

        return false;
    }

    function isRateReadyForUpdate(uint snakeId) public view returns (bool) {
        SnakeStats memory stats = getSnakeStats(snakeId);
        require(stats.HatchingTime != 0, "NFTManager: Cannot find snake with provided id");
        Egg memory properties = getEggProperties(stats.Type);

        if(stats.StakeAmount > properties.Price * stats.TimesRateUpdated * 10 && stats.APR < maxRate) {
            return true;
        }

        return false;
    }
    
    function getArtifactProperties(uint id) external override view returns (Artifact memory) {
        Artifact memory artifactPropertiesLocal = artifactsProperties[id];
        require(artifactPropertiesLocal.Price != 0, "NFTManager: Artifact with provided id does not exists");
        return artifactPropertiesLocal;
    }
    
    function getEggProperties(uint id) public override view returns (Egg memory) {
        Egg memory eggPropertiesLocal = eggsProperties[id];
        require(eggPropertiesLocal.Price != 0, "NFTManager: Egg with provided id does not exists");
        return eggPropertiesLocal;
    }

    function getSnakeProperties(uint id) public override view returns (Snake memory) {
        Snake memory snakePropertiesLocal = snakesProperties[id];
        require(snakePropertiesLocal.Type != 0, "NFTManager: Snake with provided id does not exists");
        return snakePropertiesLocal;
    }

    function getEggStats(uint tokenId) public override view returns (EggStats memory) {
        EggStats memory eggStatsLocal = eggs[tokenId];
        require(eggStatsLocal.PurchasingTime != 0, "NFTManager: Egg with provided id does not exists");
        return eggStatsLocal;
    }

    function getSnakeStats(uint tokenId) public override view returns (SnakeStats memory) {
        SnakeStats memory snakeStatsLocal = snakes[tokenId];
        require(snakeStatsLocal.HatchingTime != 0, "NFTManager: Snake with provided id does not exists");
        return snakeStatsLocal;
    }

    function hatchEgg(uint tokenId) external onlyEggOwner(tokenId) {
        require(isEggReadyForHatch(tokenId), "NFTManager: Snake is not ready for hatching");
        EggStats memory stats = getEggStats(tokenId);

        snakeEggsNFT.safeBurn(tokenId);
        snakesNFT.safeMint(msg.sender, tokenId);

        bool isLocked = stats.SnakeType == 2 ? true : false;
        
        stakingPool.stakeFor(stats.PurchasingAmount, tokenId, baseRate, isLocked);
        _updateSnakeStats(tokenId, SnakeStats(tokenId, stats.SnakeType, block.timestamp, baseRate, stats.PurchasingAmount, 0, 0, 0, 0, 0, 1, false));
        emit HatchEgg(tokenId);
    }

    function feedSnake(uint snakeId, address token, uint amount) external onlySnakeOwner(snakeId) {
        SnakeStats memory stats = getSnakeStats(snakeId);
        require(amount > 0, "NFTManager: Feed amount cannot be lower then 1");
        require(allowedTokens[token], "NFTManager: Not allowed token for feed");
        require(!stats.IsDead, "NFTManager: Snake with provided id is dead");
        uint snakeEquivalentAmount = getSnakeEquivalentAmount(token, amount);

        TransferHelper.safeTransferFrom(token, msg.sender, custodian, amount);

        snakes[snakeId].StakeAmount += snakeEquivalentAmount;
        snakes[snakeId].PreviousFeededTime = snakes[snakeId].LastFeededTime;
        snakes[snakeId].LastFeededTime = block.timestamp;
        snakes[snakeId].TimesFeeded += 1;

        if(snakeEquivalentAmount > treshold) {
            snakes[snakeId].TimesFeededMoreThanTreshold += 1;
        }

        if(stats.Type == 2 && stats.TimesFeededMoreThanTreshold == 10) {
            stakingPool.updateStakeIsLocked(snakeId, false);
        }

        stakingPool.stakeFor(snakeEquivalentAmount, snakeId, stats.APR, false);
    }

    function destroySnake(uint256 tokenId) external onlySnakeOwner(tokenId) {
        stakingPool.withdraw(tokenId);
        snakesNFT.safeBurn(tokenId);
        emit DestroySnake(tokenId);
    }

    function updateRate(uint snakeId) external {
        SnakeStats memory stats = getSnakeStats(snakeId);
        require(stats.HatchingTime != 0, "NFTManager: Cannot find snake with provided id");
        require(isRateReadyForUpdate(snakeId), "NFTManager: Cannot update rate for provided snake");
        require(!stats.IsDead, "NFTManager: Snake with provided id is dead");

        snakes[snakeId].TimesRateUpdated += 1;
        snakes[snakeId].APR += bonusRate;
    }

    function updateSnakeProperties(uint id, Snake memory properties) external override onlyAllowedAddresses() {
        snakesProperties[id] = properties;
        emit UpdateSnakeProprties(id, snakesProperties[id], properties);
    }

    function updateEggProperties(uint id, Egg memory properties) external override onlyAllowedAddresses() {
        eggsProperties[id] = properties;
        emit UpdateEggProprties(id, eggsProperties[id], properties);
    }

    function updateArtifactProperties(uint id, Artifact memory properties) external override onlyAllowedAddresses() {
        artifactsProperties[id] = properties;
        emit UpdateArtifactProprties(id, artifactsProperties[id], properties);
    }

    function updateEggStats(uint tokenId, EggStats memory stats) external override onlySnakeEggsShop() {
        require(eggs[tokenId].PurchasingTime == 0, "NFTManager: Egg with provided id already exists");
        eggs[tokenId] = stats;
        emit UpdateEggStats(tokenId, eggs[tokenId], stats);
    }

    function isFeeded(uint snakeId) public view returns (bool) {
        SnakeStats memory stats = getSnakeStats(snakeId);

        if(stats.LastFeededTime > block.timestamp - 86400 && stats.PreviousFeededTime > block.timestamp - 86400) {
            return true;
        }
        
        return false;
    }

    function applyGameResults(uint snakeId, int stakeAmount, uint gameBalance) external onlyOwner {
        _updateStakeAmount(snakeId, stakeAmount);
        _updateGameBalance(snakeId, gameBalance);
    }

    function _updateGameBalance(uint snakeId, uint amount) internal {
        SnakeStats memory stats = getSnakeStats(snakeId);
        
        if(stats.Type == 4 && isFeeded(snakeId) && amount > 0) {
            amount *= 5;
        }
        
        snakes[snakeId].GameBalance += amount;
        
        emit UpdateGameBalance(snakeId, stats.GameBalance, snakes[snakeId].GameBalance, msg.sender);
    }

    function _updateStakeAmount(uint snakeId, int amount) internal {
        SnakeStats memory stats = getSnakeStats(snakeId);
        Snake memory properties = getSnakeProperties(stats.Type);

        if(amount < 0) {
            require(int(stats.StakeAmount) > amount, "NFTManager: Snake`s stake amount lower then update amount");
            snakes[snakeId].StakeAmount -= uint((amount * -1));
        } else {
            snakes[snakeId].StakeAmount += uint(amount);
        }

        stakingPool.updateAmountForStake(snakeId, amount);
        emit UpdateStakeAmount(snakeId, stats.StakeAmount, snakes[snakeId].StakeAmount, msg.sender);

        if(snakes[snakeId].StakeAmount < properties.DeathPoint) {
            stakingPool.withdrawAndGetReward(snakeId);
            snakes[snakeId].IsDead = true;
            emit UpdateStakeIsDead(snakeId);
        }
    }

    function _updateSnakeStats(uint tokenId, SnakeStats memory stats) internal {
        require(snakes[tokenId].HatchingTime == 0, "NFTManager: Snake with provided id already exists");
        snakes[tokenId] = stats;
        emit UpdateSnakeStats(tokenId, snakes[tokenId], stats);
    }
}