//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "../objects/Objects.sol";
import "../utils/Convertable.sol";
import "../utils/Address.sol";
import "../utils/Initializable.sol";
import "../interfaces/ILockStakingRewardsPool.sol";
import "../interfaces/IBEP721Enumerable.sol";

contract NFTManagerStorage is Initializable, Convertable, Objects {    

    address internal _implementationAddress;
    
    uint public version;
    
    bytes32 public DOMAIN_SEPARATOR;
    bytes32 public APPLY_GAME_RESULTS_TYPEHASH;
    
    mapping(address => uint256) public nonces;

    mapping(uint => Snake) public snakesProperties;
    mapping(uint => Egg) public eggsProperties;
    mapping(uint => Artifact) public artifactsProperties;

    mapping(uint => SnakeStats) public snakes;
    mapping(uint => EggStats) public eggs;
    mapping(uint => ArtifactStats) public artifacts;

    mapping(address => bool) public allowedAddresses;

    mapping(address => bool) public allowedTokens;

    ILockStakingRewardsPool public stakingPool;
    IBEP721Enumerable public snakeEggsNFT;
    IBEP721Enumerable public snakesNFT;

    address public snakeEggsShop;

    uint public treshold;
    uint public baseRate;
    uint public bonusRate;
    uint public maxRate;

    address public custodian;
    
    event UpdateStakingPool(address indexed _stakingPool);
    event UpdateSnakeEggsShop(address indexed _snakeEggsShop);
    event UpdateSnakesNFT(address indexed _snakesNFT);
    event UpdateSnakeEggsNFT(address indexed _snakeEggsNFT);
    event UpdateAllowedAddresses(address indexed value, bool indexed allowance);
    event UpdateAllowedTokens(address indexed token, bool indexed allowance);
    event UpdateCustodian(address indexed newCustodian);

    function updateAllowedAddresses(address value, bool allowance) external onlyOwner {
        allowedAddresses[value] = allowance;
        emit UpdateAllowedAddresses(value, allowance);
    }

    function updateAllowedTokens(address token, bool allowance) external onlyOwner {
        allowedTokens[token] = allowance;
        emit UpdateAllowedTokens(token, allowance);
    }

    function updateSnakeEggsShop(address _snakeEggsShop) external onlyOwner {
        require(Address.isContract(_snakeEggsShop), "NFTManager: _snakeEggsShop is not a contract");
        snakeEggsShop = _snakeEggsShop;
        emit UpdateSnakeEggsShop(_snakeEggsShop);
    }
        
    function updateStakingManager(address _stakingPool) external onlyOwner {
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

    function updateTreshold(uint _treshold) external onlyOwner {
        require(_treshold > 0, "NFTManager: treshold must be grater than 0");
        treshold = _treshold;
    }

    function updateBaseRate(uint _baseRate) external onlyOwner {
        require(_baseRate > 0, "NFTManager: base rate must be grater than 0");
        baseRate = _baseRate;
    }

    function updateBonusRate(uint _bonusRate) external onlyOwner {
        require(_bonusRate > 0, "NFTManager: bonus rate must be grater than 0");
        bonusRate = _bonusRate;
    }

    function updateMaxRate(uint _maxRate) external onlyOwner {
        require(_maxRate > 0, "NFTManager: max rate must be grater than 0");
        maxRate = _maxRate;
    }

    function updateCustodian(address newCustodian) external onlyOwner {
        require(newCustodian != address(0), "NFTManager: newCustodian can't be zero address");
        custodian = newCustodian;
        emit UpdateCustodian(newCustodian);
    }
}