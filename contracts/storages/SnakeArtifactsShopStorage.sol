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

contract SnakeArtifactsShopStorage is Initializable, Allowable, Convertable, Objects, RescueManager {

    address internal _implementationAddress;

    IBEP1155 public artifactsNFT;

    INFTManager public nftManager;

    address public artifactsOwner;

    address public custodian;

    uint public version;

    mapping(address => bool) public allowedTokens;

    event UpdateArtifactsOwner(address indexed newArtifactsOwner);
    event UpdateArtifactConract(address indexed artifacts);
    event UpdateNFTManager(address indexed nftManager);
    event UpdateAllowedTokens(address indexed token, bool indexed isAllowed);
    event UpdateCustodian(address indexed newCustodian);

    function updateArtifactsOwner(address newArtifactsOwner) external onlyOwner {
        require(newArtifactsOwner != address(0), "SnakeShop: newArtifactsOwner can not be zero address");
        artifactsOwner = newArtifactsOwner;
        emit UpdateArtifactsOwner(newArtifactsOwner);
    }

    function updateArtifactConract(address _artifactsNFT) external onlyOwner {
        require(Address.isContract(_artifactsNFT), "ArtifactsShop: _artifactsNFT is not a contract");
        artifactsNFT = IBEP1155(_artifactsNFT);
        emit UpdateArtifactConract(_artifactsNFT);
    }

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
        require(newCustodian != address(0), "SnakeEggsShop: newCustodian can't be zero address");
        custodian = newCustodian;
        emit UpdateCustodian(newCustodian);
    }
}