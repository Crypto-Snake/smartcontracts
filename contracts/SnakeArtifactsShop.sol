//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;
import "./storages/SnakeArtifactsShopStorage.sol";

contract SnakeArtifactsShop is SnakeArtifactsShopStorage {

    event BuyArtifact(address indexed buyer, uint indexed artifactId, address indexed token, uint artifactCount, uint totalEquivalentPrice);

    function initialize(address _artifactsNFT, address _nftManager, address _custodian, address _artifactsOwner) external initializer {
        require(Address.isContract(_artifactsNFT), "_artifactsNFT is not a contract");
        require(Address.isContract(_nftManager), "_nftManager is not a contract");
        require(_artifactsOwner != address(0), "_artifactsOwner is zero address");

        artifactsNFT = IBEP1155(_artifactsNFT);
        nftManager = INFTManager(_nftManager);
        custodian = _custodian;
        artifactsOwner = _artifactsOwner;
    }

    function buyArtifact(uint id, address purchaseToken, uint count) external {
        require(count > 0, "ArtifactsShop: Artifacts count must be greater than 0");
        require(allowedTokens[purchaseToken], "ArtifactsShop: Buying artifacts for this token is not allowed");
        uint price = nftManager.getArtifactProperties(id).Price;
        require(price > 0, "ArtifactsShop: Artifact not found or no corresponding pair");
        
        uint finalPrice = price * count;
        TransferHelper.safeTransferFrom(purchaseToken, msg.sender, custodian, finalPrice);
        artifactsNFT.safeTransferFrom(artifactsOwner, msg.sender, id, count, "0x");
        emit BuyArtifact(msg.sender, id, purchaseToken, count, finalPrice);
    }
}