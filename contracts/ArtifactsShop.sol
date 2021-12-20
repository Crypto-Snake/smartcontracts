//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "./utils/TransferHelper.sol";
import "./utils/Allowable.sol";
import "./utils/Address.sol";
import "./utils/Counters.sol";
import "./interfaces/IBEP1155.sol";
import "./interfaces/INFTManager.sol";

contract ArtifactsShop is Allowable {
    IBEP1155 public artifactsNFT;
    address public artifactsOwner;

    INFTManager public nftManager;
    address public custodian;
    mapping(address => bool) public allowedTokens;

    event BuyArtifact(address indexed buyer, uint indexed artifactId, address indexed token, uint artifactCount, uint totalEquivalentPrice);
    event UpdateArtifactsOwner(address indexed newOwner);
    event UpdateArtifactConract(address indexed artifacts);
    event UpdateNFTManager(address indexed nftManager);
    event UpdateAllowedTokens(address indexed token, bool indexed isAllowed);
    event UpdateCustodian(address indexed newCustodian);

    constructor(address _artifactsNFT, address _nftManager, address _custodian) { 
        require(Address.isContract(_artifactsNFT), "_artifactsNFT is not a contract");
        require(Address.isContract(_nftManager), "_nftManager is not a contract");

        artifactsNFT = IBEP1155(_artifactsNFT);
        nftManager = INFTManager(_nftManager);
        custodian = _custodian;
    }

    function buyArtifact(uint id, address purchaseToken, uint count) external {
        require(count > 0, "SnakeShop: Artifacts count must be greater than 0");
        require(allowedTokens[purchaseToken], "SnakeShop: Buying artifacts for this token is not allowed");
        uint price = nftManager.getArtifactProperties(id).Price;
        require(price > 0, "SnakeShop: Artifact not found or no corresponding pair");
        
        uint finalPrice = price * count;
        TransferHelper.safeTransferFrom(purchaseToken, msg.sender, custodian, finalPrice);
        artifactsNFT.safeTransferFrom(artifactsOwner, msg.sender, id, count, "0x");
        emit BuyArtifact(msg.sender, id, purchaseToken, count, finalPrice);
    }
    
    function updateArtifactsOwner(address newOwner) external onlyOwner {
        require(newOwner != address(0), "SnakeShop: newOwner can not be zero address");
        artifactsOwner = newOwner;
        emit UpdateArtifactsOwner(newOwner);
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