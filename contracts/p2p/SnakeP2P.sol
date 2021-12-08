//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "./SnakeP2PStorage.sol";
import "../utils/Address.sol";
import "../utils/TransferHelper.sol";
import "../interfaces/IBEP721Receiver.sol";
import "../interfaces/IBEP1155.sol";
import "../interfaces/IBEP721.sol";
import "../interfaces/IBEP20Permit.sol";

contract SnakeP2P is SnakeP2PStorage, IBEP721Receiver {    
    address public target;

    receive() external payable {
        assert(msg.sender == address(WBNB)); // only accept ETH via fallback from the WBNB contract
    }
    
    modifier lock() {
        require(unlocked == 1, 'SnakeP2P: locked');
        unlocked = 0;
        _;
        unlocked = 1;
    }

    function createTrade20To20(address proposedAsset, uint proposedAmount, address askedAsset, uint askedAmount, uint deadline) external returns (uint tradeId) {
        require(Address.isContract(proposedAsset) && Address.isContract(askedAsset), "SnakeP2P: Not contracts");
        require(proposedAmount > 0, "SnakeP2P: Zero amount not allowed");
        TransferHelper.safeTransferFrom(proposedAsset, msg.sender, address(this), proposedAmount);
        tradeId = _createTradeSingle(proposedAsset, proposedAmount, 0, askedAsset, askedAmount, 0, deadline, AssetType.BEP20, AssetType.BEP20);   
    }

    // for trade BEP20 -> Native Coin use createTradeBEP20ToBEP20 and pass WBNB address as asked asset
    function createTradeBNBto20(address askedAsset, uint askedAmount, uint deadline) payable external returns (uint tradeId) {
        require(Address.isContract(askedAsset), "SnakeP2P: Not contract");
        require(msg.value > 0, "SnakeP2P: Zero amount not allowed");
        WBNB.deposit{value: msg.value}();
        tradeId = _createTradeSingle(address(WBNB), msg.value, 0, askedAsset, askedAmount, 0, deadline, AssetType.BEP20, AssetType.BEP20);   
    }



    function createTrade20To721(address proposedAsset, uint proposedAmount, address askedAsset, uint tokenId, uint deadline) external returns (uint tradeId) {
        require(Address.isContract(proposedAsset), "SnakeP2P: Not contracts");
        require(proposedAmount > 0, "SnakeP2P: Zero amount not allowed");
        _requireAllowed721Or1155(askedAsset);
        TransferHelper.safeTransferFrom(proposedAsset, msg.sender, address(this), proposedAmount);
        tradeId = _createTradeSingle(proposedAsset, proposedAmount, 0, askedAsset, 0, tokenId, deadline, AssetType.BEP20, AssetType.BEP721);   
    }

    // for trade NFT -> Native Coin use createTradeNFTtoBEP20 and pass WBNB address as asked asset
    function createTrade721to20(address proposedAsset, uint tokenId, address askedAsset, uint askedAmount, uint deadline) external returns (uint tradeId) {
        require(Address.isContract(proposedAsset), "SnakeP2P: Not contracts");
        _requireAllowed721Or1155(proposedAsset);
        IBEP721(proposedAsset).safeTransferFrom(msg.sender, address(this), tokenId);
        tradeId = _createTradeSingle(proposedAsset, 0, tokenId, askedAsset, askedAmount, 0, deadline, AssetType.BEP721, AssetType.BEP20);   
    }

    function createTradeBNBto721(address askedAsset, uint tokenId, uint deadline) payable external returns (uint tradeId) {
        require(Address.isContract(askedAsset), "SnakeP2P: Not contract");
        require(msg.value > 0, "SnakeP2P: Zero amount not allowed");
        _requireAllowed721Or1155(askedAsset);
        WBNB.deposit{value: msg.value}();
        tradeId = _createTradeSingle(address(WBNB), msg.value, 0, askedAsset, 0, tokenId, deadline, AssetType.BEP20, AssetType.BEP721);   
    }



    function createTrade1155to20(address proposedAsset, uint proposedAmount, uint proposedTokenId, address askedAsset, uint askedAmount, uint deadline) external returns (uint tradeId) {
        require(Address.isContract(proposedAsset), "SnakeP2P: Not contracts");
        require(proposedAmount > 0, "SnakeP2P: Zero amount not allowed");
        _requireAllowed721Or1155(proposedAsset);
        IBEP1155(proposedAsset).safeTransferFrom(msg.sender, address(this), proposedTokenId, proposedAmount, "");
        tradeId = _createTradeSingle(proposedAsset, proposedAmount, proposedTokenId, askedAsset, askedAmount, 0, deadline, AssetType.BEP1155, AssetType.BEP20);   
    }

    function createTrade20To1155(address proposedAsset, uint proposedAmount, address askedAsset, uint tokenId, uint askedAmount, uint deadline) external returns (uint tradeId) {
        require(Address.isContract(proposedAsset), "SnakeP2P: Not contracts");
        require(proposedAmount > 0, "SnakeP2P: Zero amount not allowed");
        _requireAllowed721Or1155(askedAsset);
        TransferHelper.safeTransferFrom(proposedAsset, msg.sender, address(this), proposedAmount);
        tradeId = _createTradeSingle(proposedAsset, proposedAmount, 0, askedAsset, askedAmount, tokenId, deadline, AssetType.BEP20, AssetType.BEP1155);   
    }

    function createTradeBNBto1155(address askedAsset, uint tokenId, uint askedAmount, uint deadline) payable external returns (uint tradeId) {
        require(Address.isContract(askedAsset), "SnakeP2P: Not contract");
        require(msg.value > 0, "SnakeP2P: Zero amount not allowed");
        _requireAllowed721Or1155(askedAsset);
        WBNB.deposit{value: msg.value}();
        tradeId = _createTradeSingle(address(WBNB), msg.value, 0, askedAsset, askedAmount, tokenId, deadline, AssetType.BEP20, AssetType.BEP1155);   
    }



    function createTrade1155To721(address proposedAsset, uint proposedAmount, uint proposedTokenId, address askedAsset, uint tokenId, uint deadline) external returns (uint tradeId) {
        require(Address.isContract(proposedAsset), "SnakeP2P: Not contracts");
        require(proposedAmount > 0, "SnakeP2P: Zero amount not allowed");
        _requireAllowed721Or1155(askedAsset);
        _requireAllowed721Or1155(proposedAsset);
        IBEP1155(proposedAsset).safeTransferFrom(msg.sender, address(this), proposedTokenId, proposedAmount, "");
        tradeId = _createTradeSingle(proposedAsset, proposedAmount, proposedTokenId, askedAsset, 0, tokenId, deadline, AssetType.BEP1155, AssetType.BEP721);   
    }

    function createTrade721to1155(address proposedAsset, uint proposedTokenId, address askedAsset, uint askedAmount, uint askedTokenId, uint deadline) external returns (uint tradeId) {
        require(Address.isContract(proposedAsset), "SnakeP2P: Not contracts");
        _requireAllowed721Or1155(askedAsset);
        _requireAllowed721Or1155(proposedAsset);
        IBEP721(proposedAsset).safeTransferFrom(msg.sender, address(this), proposedTokenId);
        tradeId = _createTradeSingle(proposedAsset, 0, proposedTokenId, askedAsset, askedAmount, askedTokenId, deadline, AssetType.BEP721, AssetType.BEP1155);   
    }



    function createTrade20To721s(
        address proposedAsset, 
        uint proposedAmount, 
        address[] memory askedAssets, 
        uint[] memory askedTokenIds, 
        uint deadline
    ) external returns (uint tradeId) {
        require(Address.isContract(proposedAsset), "SnakeP2P: Not contracts");
        require(proposedAmount > 0, "SnakeP2P: Zero amount not allowed");
        require(askedAssets.length == askedTokenIds.length, "SnakeP2P: Wrong lengths");
        for (uint256 i; i < askedAssets.length; i++) {
            require(Address.isContract(askedAssets[i]));
            _requireAllowed721Or1155(askedAssets[i]);
        }
        
        TransferHelper.safeTransferFrom(proposedAsset, msg.sender, address(this), proposedAmount);

        address[] memory proposedAssets = new address[](1);
        proposedAssets[0] = proposedAsset;
        uint[] memory proposedIds = new uint[](0);
        tradeId = _createTradeMulti(proposedAssets, proposedAmount, proposedIds, askedAssets, 0, askedTokenIds, deadline, AssetType.BEP20, AssetType.BEP721);   
    }

    // for trade NFTs -> Native Coin use createTradeNFTstoBEP20 and pass WBNB address as asked asset
    function createTrade721sTo20(
        address[] memory proposedAssets, 
        uint[] memory proposedTokenIds, 
        address askedAsset, 
        uint askedAmount, 
        uint deadline
    ) external returns (uint tradeId) {
        require(Address.isContract(askedAsset), "SnakeP2P: Not contracts");
        require(proposedAssets.length == proposedTokenIds.length, "SnakeP2P: Wrong lengths");
        
        for (uint i; i < proposedAssets.length; i++) {
          require(Address.isContract(proposedAssets[i]), "SnakeP2P: Not contracts");
          _requireAllowed721Or1155(proposedAssets[i]);
          IBEP721(proposedAssets[i]).safeTransferFrom(msg.sender, address(this), proposedTokenIds[i]);
        }
        address[] memory askedAssets = new address[](1);
        askedAssets[0] = askedAsset;
        uint[] memory askedIds = new uint[](0);
        tradeId = _createTradeMulti(proposedAssets, 0, proposedTokenIds, askedAssets, askedAmount, askedIds, deadline, AssetType.BEP721, AssetType.BEP721);   
    }

    function createTradeBNBto721s(address[] memory askedAssets, uint[] memory askedTokenIds, uint deadline) 
        payable external returns (uint tradeId) 
    {
        require(askedAssets.length == askedTokenIds.length, "SnakeP2P: Wrong lengths");
        require(msg.value > 0, "SnakeP2P: Zero amount not allowed");
        for (uint i; i < askedAssets.length; i++) {
          require(Address.isContract(askedAssets[i]), "SnakeP2P: Not contracts");
            _requireAllowed721Or1155(askedAssets[i]);
        }
        require(msg.value > 0);
        WBNB.deposit{value: msg.value}();
        address[] memory proposedAssets = new address[](1);
        proposedAssets[0] = address(WBNB);
        uint[] memory proposedIds = new uint[](0);
        tradeId = _createTradeMulti(proposedAssets, msg.value, proposedIds, askedAssets, 0, askedTokenIds, deadline, AssetType.BEP20, AssetType.BEP721);   
    }

    function createTrade721sTo721s(
        address[] memory proposedAssets, 
        uint[] memory proposedTokenIds, 
        address[] memory askedAssets, 
        uint[] memory askedTokenIds, 
        uint deadline
    ) external returns (uint tradeId) {
        for (uint i; i < askedAssets.length; i++) {
          require(Address.isContract(askedAssets[i]), "SnakeP2P: Not contracts");
          _requireAllowed721Or1155(askedAssets[i]);
        }

        for (uint i; i < proposedAssets.length; i++) {
          require(Address.isContract(proposedAssets[i]), "SnakeP2P: Not contracts");
          _requireAllowed721Or1155(proposedAssets[i]);
          IBEP721(proposedAssets[i]).safeTransferFrom(msg.sender, address(this), proposedTokenIds[i]);
        }        
        tradeId = _createTradeMulti(proposedAssets, 0, proposedTokenIds, askedAssets, 0, askedTokenIds, deadline, AssetType.BEP721, AssetType.BEP721);   
    }



    function createTrade20To20Permit(
        address proposedAsset, 
        uint proposedAmount, 
        address askedAsset, 
        uint askedAmount, 
        uint deadline, 
        uint permitDeadline, 
        uint8 v, 
        bytes32 r, 
        bytes32 s
    ) external returns (uint tradeId) {
        require(Address.isContract(proposedAsset) && Address.isContract(askedAsset), "SnakeP2P: Not contracts");
        require(proposedAmount > 0, "SnakeP2P: Zero amount not allowed");
        IBEP20Permit(proposedAsset).permit(msg.sender, address(this), proposedAmount, permitDeadline, v, r, s);
        TransferHelper.safeTransferFrom(proposedAsset, msg.sender, address(this), proposedAmount);
        tradeId = _createTradeSingle(proposedAsset, proposedAmount, 0, askedAsset, askedAmount, 0, deadline, AssetType.BEP20, AssetType.BEP20);   
    }

    function createTrade20To721Permit(
        address proposedAsset, 
        uint proposedAmount, 
        address askedAsset, 
        uint tokenId, 
        uint deadline, 
        uint permitDeadline, 
        uint8 v, 
        bytes32 r, 
        bytes32 s
    ) external returns (uint tradeId) {
        require(Address.isContract(proposedAsset), "SnakeP2P: Not contracts");
        require(proposedAmount > 0, "SnakeP2P: Zero amount not allowed");
        IBEP20Permit(proposedAsset).permit(msg.sender, address(this), proposedAmount, permitDeadline, v, r, s);
        TransferHelper.safeTransferFrom(proposedAsset, msg.sender, address(this), proposedAmount);
        tradeId = _createTradeSingle(proposedAsset, proposedAmount, 0, askedAsset, 0, tokenId, deadline, AssetType.BEP20, AssetType.BEP721);   
    }

    function createTrade20To721sPermit(
        address proposedAsset, 
        uint proposedAmount, 
        address[] memory askedAssets, 
        uint[] memory askedTokenIds, 
        uint deadline, 
        uint permitDeadline, 
        uint8 v, 
        bytes32 r, 
        bytes32 s
    ) external returns (uint tradeId) {
        require(Address.isContract(proposedAsset), "SnakeP2P: Not contracts");
        require(proposedAmount > 0, "SnakeP2P: Zero amount not allowed");
        require(askedAssets.length == askedTokenIds.length, "SnakeP2P: Wrong lengths");
        IBEP20Permit(proposedAsset).permit(msg.sender, address(this), proposedAmount, permitDeadline, v, r, s);
        TransferHelper.safeTransferFrom(proposedAsset, msg.sender, address(this), proposedAmount);

        address[] memory proposedAssets = new address[](1);
        proposedAssets[0] = proposedAsset;
        uint[] memory proposedIds = new uint[](0);
        tradeId = _createTradeMulti(proposedAssets, proposedAmount, proposedIds, askedAssets, 0, askedTokenIds, deadline, AssetType.BEP20, AssetType.BEP721);   
    }



    function supportTradeSingle(uint tradeId) external lock {
        require(tradeCount >= tradeId && tradeId > 0, "SnakeP2P: Invalid trade id");
        TradeSingle storage trade = tradesSingle[tradeId];
        require(trade.status == 0 && trade.deadline > block.timestamp, "SnakeP2P: Not active trade");

        if (trade.askedAssetType == AssetType.BEP721) {
            IBEP721(trade.askedAsset).safeTransferFrom(msg.sender, trade.initiator, trade.askedTokenId);
        } else if (trade.askedAssetType == AssetType.BEP1155) {
            IBEP1155(trade.askedAsset).safeTransferFrom(msg.sender, trade.initiator, trade.askedTokenId, trade.askedAmount, "");
        } else {
            TransferHelper.safeTransferFrom(trade.askedAsset, msg.sender, trade.initiator, trade.askedAmount);
        }
        _supportTradeSingle(tradeId);
    }

    function supportTradeSingleBNB(uint tradeId) payable external lock {
        require(tradeCount >= tradeId && tradeId > 0, "SnakeP2P: Invalid trade id");
        TradeSingle storage trade = tradesSingle[tradeId];
        require(trade.status == 0 && trade.deadline > block.timestamp, "SnakeP2P: Not active trade");
        require(msg.value >= trade.askedAmount, "SnakeP2P: Not enough BNB sent");
        require(trade.askedAsset == address(WBNB), "SnakeP2P: BEP20 trade");

        TransferHelper.safeTransferBNB(trade.initiator, trade.askedAmount);
        if (msg.value > trade.askedAmount) TransferHelper.safeTransferBNB(msg.sender, msg.value - trade.askedAmount);
        _supportTradeSingle(tradeId);
    }
    
    function supportTradeSingleWithPermit(uint tradeId, uint permitDeadline, uint8 v, bytes32 r, bytes32 s) external lock {
        require(tradeCount >= tradeId && tradeId > 0, "NimbusBEP20P2P_V1: Invalid trade id");
        TradeSingle storage trade = tradesSingle[tradeId];
        require(trade.askedAssetType == AssetType.BEP20, "NimbusBEP20P2P_V1: Permit only allowed for BEP20 tokens");
        require(trade.status == 0 && trade.deadline > block.timestamp, "NimbusBEP20P2P_V1: Not active trade");

        IBEP20Permit(trade.askedAsset).permit(msg.sender, address(this), trade.askedAmount, permitDeadline, v, r, s);
        TransferHelper.safeTransferFrom(trade.askedAsset, msg.sender, trade.initiator, trade.askedAmount);
        _supportTradeSingle(tradeId);
    }

    function supportTradeMulti(uint tradeId) external lock {
        require(tradeCount >= tradeId && tradeId > 0, "SnakeP2P: Invalid trade id");
        TradeMulti storage tradeMulti = tradesMulti[tradeId];
        require(tradeMulti.status == 0 && tradeMulti.deadline > block.timestamp, "SnakeP2P: Not active trade");
        if (tradeMulti.askedAssetType == AssetType.BEP721) {
            for (uint i; i < tradeMulti.askedAssets.length; i++) {
                IBEP721(tradeMulti.askedAssets[i]).safeTransferFrom(msg.sender, tradeMulti.initiator, tradeMulti.askedTokenIds[i]);
            }
        } else if (tradeMulti.askedAssetType == AssetType.BEP1155) {
            IBEP1155(tradeMulti.askedAssets[0]).safeTransferFrom(msg.sender, tradeMulti.initiator, tradeMulti.askedTokenIds[0], tradeMulti.askedAmount, "");
        } else {
            TransferHelper.safeTransferFrom(tradeMulti.askedAssets[0], msg.sender, tradeMulti.initiator, tradeMulti.askedAmount);
        }

        _supportTradeMulti(tradeId);
    }   



    function cancelTrade(uint tradeId) external lock { 
        require(tradeCount >= tradeId && tradeId > 0, "SnakeP2P: Invalid trade id");
        require(tradesSingle[tradeId].initiator == msg.sender, "SnakeP2P: Not allowed");
        _cancelTrade(tradeId);
    }

    function cancelTradeMulti(uint tradeId) external lock { 
        require(tradeCount >= tradeId && tradeId > 0, "SnakeP2P: Invalid trade id");
        TradeMulti storage tradeMulti = tradesMulti[tradeId];
        require(tradeMulti.initiator == msg.sender, "SnakeP2P: Not allowed");
        require(tradeMulti.status == 0 && tradeMulti.deadline > block.timestamp, "SnakeP2P: Not active trade");

        if (tradeMulti.proposedAssetType == AssetType.BEP721) {
            for (uint i; i < tradeMulti.proposedAssets.length; i++) {           
                IBEP721(tradeMulti.proposedAssets[i]).transferFrom(address(this), msg.sender, tradeMulti.proposedTokenIds[i]);
            } 
        } else if (tradeMulti.proposedAssetType == AssetType.BEP1155) {
            IBEP1155(tradeMulti.proposedAssets[0]).safeTransferFrom(address(this), msg.sender, tradeMulti.proposedTokenIds[0], tradeMulti.proposedAmount, "");
        } else if (tradeMulti.proposedAssets[0] != address(WBNB)) {
            TransferHelper.safeTransfer(tradeMulti.proposedAssets[0], msg.sender, tradeMulti.proposedAmount);
        } else {
            WBNB.withdraw(tradeMulti.proposedAmount);
            TransferHelper.safeTransferBNB(msg.sender, tradeMulti.proposedAmount);
        }
        
        tradeMulti.status = 2;
        emit CancelTrade(tradeId);
    }



    function withdrawOverdueAssetSingle(uint tradeId) external lock { 
        require(tradeCount >= tradeId && tradeId > 0, "SnakeP2P: Invalid trade id");
        TradeSingle storage trade = tradesSingle[tradeId];
        require(trade.initiator == msg.sender, "SnakeP2P: Not allowed");
        require(trade.status == 0 && trade.deadline < block.timestamp, "SnakeP2P: Not available for withdrawal");

        if (trade.proposedAssetType == AssetType.BEP721) {
            IBEP721(trade.proposedAsset).transferFrom(address(this), msg.sender, trade.proposedTokenId);
        } else if (trade.proposedAssetType == AssetType.BEP1155) {
            IBEP1155(trade.proposedAsset).safeTransferFrom(address(this), msg.sender, trade.proposedTokenId, trade.proposedAmount, "");
        } else if (trade.proposedAsset != address(WBNB)) {
            TransferHelper.safeTransfer(trade.proposedAsset, msg.sender, trade.proposedAmount);
        } else {
            WBNB.withdraw(trade.proposedAmount);
            TransferHelper.safeTransferBNB(msg.sender, trade.proposedAmount);
        }

        trade.status = 3;
        emit WithdrawOverdueAsset(tradeId);
    }

    function withdrawOverdueAssetsMulti(uint tradeId) external lock { 
        require(tradeCount >= tradeId && tradeId > 0, "SnakeP2P: Invalid trade id");
        TradeMulti storage tradeMulti = tradesMulti[tradeId];
        require(tradeMulti.initiator == msg.sender, "SnakeP2P: Not allowed");
        require(tradeMulti.status == 0 && tradeMulti.deadline < block.timestamp, "SnakeP2P: Not available for withdrawal");
        
        if (tradeMulti.proposedAssetType == AssetType.BEP721) {
            for (uint i; i < tradeMulti.proposedAssets.length; i++) {           
                IBEP721(tradeMulti.proposedAssets[i]).transferFrom(address(this), msg.sender, tradeMulti.proposedTokenIds[i]);
            } 
        } else if (tradeMulti.proposedAssetType == AssetType.BEP1155) {
            IBEP1155(tradeMulti.proposedAssets[0]).safeTransferFrom(address(this), msg.sender, tradeMulti.proposedTokenIds[0], tradeMulti.proposedAmount, "");
        } else if (tradeMulti.proposedAssets[0] != address(WBNB)) {
            TransferHelper.safeTransfer(tradeMulti.proposedAssets[0], msg.sender, tradeMulti.proposedAmount);
        } else {
            WBNB.withdraw(tradeMulti.proposedAmount);
            TransferHelper.safeTransferBNB(msg.sender, tradeMulti.proposedAmount);
        }

        tradeMulti.status = 3;
        emit WithdrawOverdueAsset(tradeId);
    }
    


    function onBEP721Received(address operator, address from, uint256 tokenId, bytes memory data) external pure returns (bytes4) {
        return 0x150b7a02;
    }

    function getTradeMulti(uint id) external view returns(TradeMulti memory) {
        return tradesMulti[id];
    }

    function state(uint tradeId) public view returns (TradeState) { //TODO
        require(tradeCount >= tradeId && tradeId > 0, "SnakeP2P: Invalid trade id");
        TradeSingle storage trade = tradesSingle[tradeId];
        if (trade.status == 1) {
            return TradeState.Succeeded;
        } else if (trade.status == 2 || trade.status == 3) {
            return TradeState(trade.status);
        } else if (trade.deadline < block.timestamp) {
            return TradeState.Overdue;
        } else {
            return TradeState.Active;
        }
    }

    function stateMulti(uint tradeId) public view returns (TradeState) { //TODO
        require(tradeCount >= tradeId && tradeId > 0, "SnakeP2P: Invalid trade id");
        TradeMulti storage tradeMulti = tradesMulti[tradeId];
        if (tradeMulti.status == 1) {
            return TradeState.Succeeded;
        } else if (tradeMulti.status == 2 || tradeMulti.status == 3) {
            return TradeState(tradeMulti.status);
        } else if (tradeMulti.deadline < block.timestamp) {
            return TradeState.Overdue;
        } else {
            return TradeState.Active;
        }
    }

    function userTrades(address user) public view returns (uint[] memory) {
        return _userTrades[user];
    }

    function _requireAllowed721Or1155(address nftContract) private view {
        require(isAnyNFTAllowed || allowedNFT[nftContract], "SnakeP2P: Not allowed NFT");
    }

    function _createTradeSingle(
        address proposedAsset, 
        uint proposedAmount, 
        uint proposedTokenId, 
        address askedAsset, 
        uint askedAmount, 
        uint askedTokenId, 
        uint deadline, 
        AssetType proposedAssetType,
        AssetType askedAssetType
    ) private returns (uint tradeId) { 
        require(askedAsset != proposedAsset, "SnakeP2P: Asked asset can't be equal to proposed asset");
        require(deadline > block.timestamp, "SnakeP2P: Incorrect deadline");
        tradeId = ++tradeCount;
        
        TradeSingle storage trade = tradesSingle[tradeId];
        trade.initiator = msg.sender;
        trade.proposedAsset = proposedAsset;
        if (proposedAmount > 0) trade.proposedAmount = proposedAmount;
        if (proposedTokenId > 0) trade.proposedTokenId = proposedTokenId;
        trade.askedAsset = askedAsset;
        if (askedAmount > 0) trade.askedAmount = askedAmount;
        if (askedTokenId > 0) trade.askedTokenId = askedTokenId;
        trade.deadline = deadline;
        trade.proposedAssetType = proposedAssetType; 
        trade.askedAssetType = askedAssetType; 
        
        _userTrades[msg.sender].push(tradeId);        
        emit NewTradeSingle(msg.sender, proposedAsset, proposedAmount, proposedTokenId, askedAsset, askedAmount, askedTokenId, deadline, tradeId);
    }

    function _createTradeMulti(
        address[] memory proposedAssets, 
        uint proposedAmount, 
        uint[] memory proposedTokenIds, 
        address[] memory askedAssets, 
        uint askedAmount, 
        uint[] memory askedTokenIds, 
        uint deadline, 
        AssetType proposedAssetType,
        AssetType askedAssetType
    ) private returns (uint tradeId) { 
        require(deadline > block.timestamp, "SnakeP2P: Incorrect deadline");
        tradeId = ++tradeCount;
        
        TradeMulti storage tradeMulti = tradesMulti[tradeId];
        tradeMulti.initiator = msg.sender;
        tradeMulti.proposedAssets = proposedAssets;
        if (proposedAmount > 0) tradeMulti.proposedAmount = proposedAmount;
        if (proposedTokenIds.length > 0) tradeMulti.proposedTokenIds = proposedTokenIds;
        tradeMulti.askedAssets = askedAssets;
        if (askedAmount > 0) tradeMulti.askedAmount = askedAmount;
        if (askedTokenIds.length > 0) tradeMulti.askedTokenIds = askedTokenIds;
        tradeMulti.deadline = deadline;
        tradeMulti.proposedAssetType = proposedAssetType; 
        tradeMulti.askedAssetType = askedAssetType;
        
        _userTrades[msg.sender].push(tradeId);       
        emit NewTradeMulti(msg.sender, proposedAssets, proposedAmount, proposedTokenIds, askedAssets, askedAmount, askedTokenIds, deadline, tradeId);
    }

    function _supportTradeSingle(uint tradeId) private { 
        TradeSingle memory trade = tradesSingle[tradeId];
        
        if (trade.proposedAssetType == AssetType.BEP721) {
            IBEP721(trade.proposedAsset).transferFrom(address(this), msg.sender, trade.proposedTokenId);
        } else if (trade.proposedAssetType == AssetType.BEP1155) {
            IBEP1155(trade.proposedAsset).safeTransferFrom(address(this), msg.sender, trade.proposedTokenId, trade.proposedAmount, "");
        } else if (trade.proposedAsset != address(WBNB)) {
            TransferHelper.safeTransfer(trade.proposedAsset, msg.sender, trade.proposedAmount);
        } else {
            WBNB.withdraw(trade.proposedAmount);
            TransferHelper.safeTransferBNB(msg.sender, trade.proposedAmount);
        }
        
        tradesSingle[tradeId].counterparty = msg.sender;
        tradesSingle[tradeId].status = 1;
        emit SupportTrade(tradeId, msg.sender);
    }

    function _supportTradeMulti(uint tradeId) private { 
        TradeMulti memory tradeMulti = tradesMulti[tradeId];

        if (tradeMulti.proposedAssetType == AssetType.BEP721) {
            for (uint i; i < tradeMulti.proposedAssets.length; i++) {           
                IBEP721(tradeMulti.proposedAssets[i]).transferFrom(address(this), msg.sender, tradeMulti.proposedTokenIds[i]);
            }
        } else if (tradeMulti.proposedAssetType == AssetType.BEP1155) { 
            IBEP1155(tradeMulti.proposedAssets[0]).safeTransferFrom(address(this), msg.sender, tradeMulti.proposedTokenIds[0], tradeMulti.proposedAmount, "");
        } else if (tradeMulti.proposedAssets[0] != address(WBNB)) {
            TransferHelper.safeTransfer(tradeMulti.proposedAssets[0], msg.sender, tradeMulti.proposedAmount);
        } else {
            WBNB.withdraw(tradeMulti.proposedAmount);
            TransferHelper.safeTransferBNB(msg.sender, tradeMulti.proposedAmount);
        }

        tradesMulti[tradeId].counterparty = msg.sender;
        tradesMulti[tradeId].status = 1;
        emit SupportTrade(tradeId, msg.sender);
    }

    function _cancelTrade(uint tradeId) internal { 
        TradeSingle storage trade = tradesSingle[tradeId];
        require(trade.status == 0 && trade.deadline > block.timestamp, "SnakeP2P: Not active trade");

        if (trade.proposedAssetType == AssetType.BEP721) {
            IBEP721(trade.proposedAsset).transferFrom(address(this), trade.initiator, trade.proposedTokenId);
        } else if (trade.proposedAssetType == AssetType.BEP1155) {
            IBEP1155(trade.proposedAsset).safeTransferFrom(address(this), trade.initiator, trade.proposedTokenId, trade.proposedAmount, "");
        } else if (trade.proposedAsset != address(WBNB)) {
            TransferHelper.safeTransfer(trade.proposedAsset, trade.initiator, trade.proposedAmount);
        } else {
            WBNB.withdraw(trade.proposedAmount);
            TransferHelper.safeTransferBNB(trade.initiator, trade.proposedAmount);
        }

        trade.status = 2;
        emit CancelTrade(tradeId);
    }



    function cancelTradeFor(uint tradeId) external lock onlyOwner { 
        require(tradeCount >= tradeId && tradeId > 0, "SnakeP2P: Invalid trade id");
        _cancelTrade(tradeId);
    }

    function toggleAnyNFTAllowed() external onlyOwner {
        isAnyNFTAllowed = !isAnyNFTAllowed;
        emit UpdateIsAnyNFTAllowed(isAnyNFTAllowed);
    }

    function updateAllowedNFT(address nft, bool isAllowed) external onlyOwner {
        require(Address.isContract(nft), "SnakeP2P: Not a contract");
        allowedNFT[nft] = isAllowed;
        emit UpdateAllowedNFT(nft, isAllowed);
    }
}