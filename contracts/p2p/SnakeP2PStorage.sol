//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "../utils/Ownable.sol";
import "../objects/TradeObjects.sol";
import "../interfaces/IWBNB.sol";

enum TradeState {
    Active,
    Succeeded,
    Canceled,
    Withdrawn,
    Overdue
}

contract SnakeP2PStorage is Ownable, TradeObjects {    
    IWBNB public constant WBNB = IWBNB(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    uint public tradeCount;
    mapping(uint => TradeSingle) public tradesSingle;
    mapping(uint => TradeMulti) public tradesMulti;
    mapping(address => uint[]) internal _userTrades;

    bool public isAnyNFTAllowed;
    mapping(address => bool) public allowedNFT;

    uint internal unlocked = 1;

    event NewTradeSingle(address indexed user, address indexed proposedAsset, uint proposedAmount, uint proposedTokenId, address indexed askedAsset, uint askedAmount, uint askedTokenId, uint deadline, uint tradeId);
    event NewTradeMulti(address indexed user, address[] proposedAssets, uint proposedAmount, uint[] proposedIds, address[] askedAssets, uint askedAmount, uint[] askedIds, uint deadline, uint indexed tradeId);
    event SupportTrade(uint indexed tradeId, address indexed counterparty);
    event CancelTrade(uint indexed tradeId);
    event WithdrawOverdueAsset(uint indexed tradeId);
    event UpdateIsAnyNFTAllowed(bool indexed isAllowed);
    event UpdateAllowedNFT(address indexed nftContract, bool indexed isAllowed);
}