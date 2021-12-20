//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "../utils/Allowable.sol";
import "../utils/RescueManager.sol";
import "../utils/Convertable.sol";
import "../utils/TransferHelper.sol";
import "../utils/Initializable.sol";
import "../utils/Counters.sol";
import "../interfaces/IBEP20.sol";
import "../interfaces/IBEP721Enumerable.sol";
import "../interfaces/IBEP1155.sol";
import "../interfaces/INFTManager.sol";
import "../objects/Objects.sol";

contract SnakeEggsShopStorage is Initializable, Allowable, Convertable, Objects, RescueManager {
    using Counters for Counters.Counter;

    address internal _implementationAddress;
    
    IBEP721Enumerable public snakeEggsNFT;

    Counters.Counter public counter;

    INFTManager public nftManager;

    address public custodian;

    uint public version;

    mapping(address => bool) public allowedTokens;

    event UpdateStakingManager(address indexed stakingManager);
    event UpdateNFTManager(address indexed nftManager);
    event UpdateAllowedTokens(address indexed token, bool indexed isAllowed);
    event UpdateCustodian(address indexed newCustodian);

    function updateNFTManager(address _nftManager) external onlyOwner {
        require(Address.isContract(_nftManager), "SnakeEggsShop: _nftManager is not a contract");
        nftManager = INFTManager(_nftManager);
        emit UpdateNFTManager(_nftManager);
    }

    function updateAllowedTokens(address token, bool isAllowed) external onlyOwner {
        require(Address.isContract(token), "SnakeEggsShop: token is not a contract");
        allowedTokens[token] = isAllowed;
        emit UpdateAllowedTokens(token, isAllowed);
    }

    function updateCustodian(address newCustodian) external onlyOwner {
        require(newCustodian != address(0), "SnakeEggsShop: newCustodian can not be zero address");
        custodian = newCustodian;
        emit UpdateCustodian(newCustodian);
    }

    function setCurrentEggId(uint id) external onlyOwner {
        Counters.setValue(counter, id);
    }
}