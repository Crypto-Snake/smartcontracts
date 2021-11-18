// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "../objects/Objects.sol";
import "../utils/Ownable.sol";
import "../utils/Address.sol";
import "../utils/Initializable.sol";
import "../interfaces/ILockStakingRewardsPool.sol";
import "../interfaces/INFTManager.sol";

abstract contract BaseTokenStorage is Initializable, Ownable, Objects {
    using Address for address;

    address internal _implementationAddress;

    ILockStakingRewardsPool public stakingPool;
    INFTManager public nftManager;

    uint public version;

    address public snakeEggsShop;

    string internal _name;
    string internal _symbol;

    mapping(uint256 => address) internal _owners;
    mapping(address => uint256) internal _balances;

    // Mapping from token ID to approved address
    mapping(uint256 => address) internal _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) internal _operatorApprovals;

    // Mapping from owner to list of owned token IDs
    mapping(address => mapping(uint256 => uint256)) internal _ownedTokens;

    // Mapping from token ID to index of the owner tokens list
    mapping(uint256 => uint256) internal _ownedTokensIndex;

    // Array with all token ids, used for enumeration
    uint256[] internal _allTokens;

    // Mapping from token id to position in the allTokens array
    mapping(uint256 => uint256) internal _allTokensIndex;

    event UpdateStakingPool(address indexed _stakingPool);
    event UpdateNFTManager(address indexed _nftManager);
    event UpdateSnakeEggsShop(address indexed _snakeEggsShop);

    function updateStakingPool(address stakingPool_) external onlyOwner {
        require(Address.isContract(stakingPool_), "BaseTokenStorage: stakingPool_ is not a contract");
        stakingPool = ILockStakingRewardsPool(stakingPool_);
        emit UpdateStakingPool(stakingPool_);
    }

    function updateNFTManager(address nftManager_) external onlyOwner {
        require(Address.isContract(nftManager_), "BaseTokenStorage: nftManager_ is not a contract");
        nftManager = INFTManager(nftManager_);
        emit UpdateNFTManager(nftManager_);
    }

    function updateSnakeEggsShop(address snakeEggsShop_) external onlyOwner {
        require(Address.isContract(snakeEggsShop_), "BaseTokenStorage: snakeEggsShop_ is not a contract");
        snakeEggsShop = snakeEggsShop_;
        emit UpdateSnakeEggsShop(snakeEggsShop_);
    }
}