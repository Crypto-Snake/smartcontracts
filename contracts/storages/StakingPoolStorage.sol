// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "../objects/Objects.sol";
import "../objects/StakeObjects.sol";
import "../utils/Address.sol";
import "../utils/Initializable.sol";
import "../utils/Convertable.sol";
import "../utils/RescueManager.sol";
import "../utils/ReentrancyGuard.sol";
import "../interfaces/IBEP20.sol";
import "../interfaces/INFTManager.sol";

abstract contract StakingPoolStorage is Initializable, Convertable, ReentrancyGuard, RescueManager, StakeObjects, Objects {
    using Address for address;

    address internal _implementationAddress;

    uint public version;

    IBEP20 public stakingToken;
    IBEP20 public stableCoin;
    INFTManager public nftManager;

    uint256 public constant rewardDuration = 365 days;

    uint public pythonBonusRate = 27e14;
  
    mapping(uint256 => uint256) public stakeNonces;

    mapping(uint256 => mapping(uint256 => StakeInfo)) public stakeInfo;
    mapping(uint256 => TokenStakeInfo) public tokenStakeInfo;

    uint256 internal _totalSupply;

    event UpdatePythonBonusRate(uint indexed rate);
    event UpdateNFTManager(address indexed nftManager);
    event UpdateStableCoin(address indexed stableCoin);
    
    function updatePythonBonusRate(uint rate) external onlyOwner {
        pythonBonusRate = rate;
        emit UpdatePythonBonusRate(rate);
    }

    function updateNFTManager(address _nftManager) external onlyOwner {
        require(Address.isContract(_nftManager), "SnakeEggsShop: _nftManager is not a contract");
        nftManager = INFTManager(_nftManager);
        emit UpdateNFTManager(_nftManager);
    }

    function updateStableCoin(address _stableCoin) external onlyOwner {
        require(Address.isContract(_stableCoin), "SnakeEggsShop: _stableCoin is not a contract");
        stableCoin = IBEP20(_stableCoin);
        emit UpdateStableCoin(_stableCoin);
    }
}