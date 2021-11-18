//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "./AssetType.sol";

abstract contract TradeSingleStruct {
    struct TradeSingle {
        address initiator;
        address counterparty;
        address proposedAsset;
        uint proposedAmount;
        uint proposedTokenId;
        address askedAsset;
        uint askedAmount;
        uint askedTokenId;
        uint deadline;
        uint status; //0: Active, 1: success, 2: canceled, 3: withdrawn
        AssetType proposedAssetType;
        AssetType askedAssetType;
    }
}