//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "./NFTShop.sol";
import "./utils/TransferHelper.sol";

contract ArtifactsShop is NFTShop {
    IBEP1155 public artifactsNFT;
    address public artifactsOwner;

    event BuyArtifact(address indexed buyer, uint indexed artifactId, address indexed token, uint artifactCount, uint totalEquivalentPrice);
    event UpdateArtifactsOwner(address indexed newOwner);
    event UpdateArtifactConract(address indexed artifacts);

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
}