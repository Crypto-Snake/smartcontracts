//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "./AssetType.sol";

abstract contract TradeMultiStruct {
    struct TradeMulti {
        address initiator;
        address counterparty;
        address[] proposedAssets;
        uint proposedAmount;
        uint[] proposedTokenIds;
        address[] askedAssets;
        uint[] askedTokenIds;
        uint askedAmount;
        uint deadline;
        uint status; //0: Active, 1: success, 2: canceled, 3: withdrawn
        AssetType proposedAssetType;
        AssetType askedAssetType;
    }
}