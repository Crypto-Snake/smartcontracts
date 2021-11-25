//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "../objects/Objects.sol";
import "../utils/Convertable.sol";
import "../utils/Address.sol";
import "../utils/EnumerableBytes32Set.sol";
import "../interfaces/ILockStakingRewardsPool.sol";
import "../interfaces/IBEP721Enumerable.sol";
import "../interfaces/IBEP1155.sol";

contract NFTManagerStorage is Convertable, Objects {
    using EnumerableBytes32Set for EnumerableBytes32Set.Bytes32Set;

    mapping (bytes4 => address) public logicTargets;
    EnumerableBytes32Set.Bytes32Set internal logicTargetsSet;
    
    uint public version;
    
    bytes32 public DOMAIN_SEPARATOR;
    bytes32 public APPLY_GAME_RESULTS_TYPEHASH;
    bytes32 public UPDATE_GAME_BALANCE_TYPEHASH;
    bytes32 public UPDATE_STAKE_AMOUNT_TYPEHASH;
    bytes32 public APPLY_ARTIFACT_TYPEHASH;
    
    mapping(address => uint256) public applyGameResultsNonces;
    mapping(address => uint256) public updateGameBalanceNonces;
    mapping(address => uint256) public updateStakeAmountNonces;
    mapping(address => uint256) public applyArtifactNonces;

    mapping(uint => Snake) public snakesProperties;
    mapping(uint => Egg) public eggsProperties;
    mapping(uint => Artifact) public artifactsProperties;

    mapping(uint => SnakeStats) public snakes;
    mapping(uint => EggStats) public eggs;
    mapping(uint => ArtifactStats) public artifacts;

    mapping(uint => SnakeAppliedArtifacts) public snakeAppliedArtifacts;

    mapping(address => bool) public allowedTokens;
    mapping(uint => bool) public allowedArtifacts;

    ILockStakingRewardsPool public stakingPool;
    IBEP721Enumerable public snakeEggsNFT;
    IBEP721Enumerable public snakesNFT;
    IBEP1155 public artifactsNFT;

    address public snakeEggsShop;

    uint public treshold;
    uint public baseRate = 60 * percentPrecision;
    uint public bonusRate = 5 * percentPrecision;
    uint public maxRate = 110 * percentPrecision;

    address public custodian;

    uint public diamondAPRBonus = 60e18 * percentPrecision;
    uint public mouseTVLBonus = 10 * percentPrecision;
    uint public shadowSnakeRequiredTVL = 100e18;
    uint public shadowSnakeDestroyLockPeriod = 30 days;
    uint public shadowSnakeTVLMultiplier = 2;
    uint public diamondMaxAppliances = 4;

    uint public promocodeAPRBonus = 10 * percentPrecision;

    mapping(uint => mapping(uint => bool)) public artifactsApplied;
    
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
    event UpdateBonusRate(uint bonusRate);
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

    function updateBonusRate(uint _bonusRate) external onlyOwner {
        require(_bonusRate > 0, "NFTManager: bonus rate must be grater than 0");
        bonusRate = _bonusRate;
        emit UpdateBonusRate(_bonusRate);
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

    function updateShadowSnakeRequiredTVL(uint requiredTVL) external onlyOwner {
        require(requiredTVL > 0, "NFTManager: required TVL bonus must be grater than 0");
        shadowSnakeRequiredTVL = requiredTVL;
        emit UpdateShadowSnakeRequiredTVL(requiredTVL);
    }

    function updateShadowSnakeDestroyLockPeriod(uint lockPeriod) external onlyOwner {
        require(lockPeriod > 0, "NFTManager: lock period bonus must be grater than 0");
        shadowSnakeDestroyLockPeriod = lockPeriod;
        emit UpdateShadowSnakeDestroyLockPeriod(lockPeriod);
    }

    function updateShadowSnakeTVLMultiplier(uint tvlMultiplier) external onlyOwner {
        require(tvlMultiplier > 0, "NFTManager: TVL multiplier bonus must be grater than 0");
        shadowSnakeTVLMultiplier = tvlMultiplier;
        emit UpdateShadowSnakeTVLMultiplier(tvlMultiplier);
    }

    function updateDiamondMaxAppliances(uint maxAppliances) external onlyOwner {
        require(maxAppliances > 0, "NFTManager: Diamond max appliances count must be grater than 0");
        diamondMaxAppliances = maxAppliances;
        emit UpdateDiamondMaxAppliances(maxAppliances);
    }

    function _setTarget(
        bytes4 sig,
        address target)
        internal
    {
        logicTargets[sig] = target;

        if (target != address(0)) {
            logicTargetsSet.addBytes32(bytes32(sig));
        } else {
            logicTargetsSet.removeBytes32(bytes32(sig));
        }
    }
}