//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "./storages/SnakeEggsShopStorage.sol";

contract SnakeEggsShop is SnakeEggsShopStorage {
    event BuyEgg(address indexed buyer, address receiver, uint eggId, uint typeId, address indexed token, uint indexed purchaseAmount, uint purchaseTime);
    event AirdropEgg(address receiver, uint eggId, uint typeId, uint airdropTime);

    function initialize(address _router, address _snakeEggsNFT, address _nftManager, address _snakeToken, address _custodian) external initializer { 
        require(Address.isContract(_snakeEggsNFT), "_snakeEggsNFT is not a contract");
        require(Address.isContract(_router), "_router is not a contract");
        require(Address.isContract(_nftManager), "_nftManager is not a contract");
        require(Address.isContract(_snakeToken), "_snakeToken is not a contract");

        snakeEggsNFT = IBEP721Enumerable(_snakeEggsNFT);
        router = IRouter(_router);
        nftManager = INFTManager(_nftManager);
        snakeToken = _snakeToken;
        custodian = _custodian;
    }

    function buyEgg(uint typeId, address purchaseToken, uint purchaseTokenAmount) external {
        _buyEgg(typeId, purchaseToken, purchaseTokenAmount, msg.sender);
    }

    function buyEggFor(uint typeId, address purchaseToken, uint purchaseTokenAmount, address receiver) external {
        _buyEgg(typeId, purchaseToken, purchaseTokenAmount, receiver);
    }

    function buyEggsFor(uint typeId, address[] memory receivers) external {
        _buyEggsOrAirdrop(typeId, receivers, true);
    }

    function airdropEggsFor(uint typeId, address[] memory receivers) external onlyOwner {
        _buyEggsOrAirdrop(typeId, receivers, false);
    }         

        

    function updateSnakeEggsNFT(address _snakeEggsNFT) external onlyOwner {
        require(Address.isContract(_snakeEggsNFT), "BaseTokenStorage: _snakeEggsNFT is not a contract");
        snakeEggsNFT = IBEP721Enumerable(_snakeEggsNFT);
    }

    function _buyEgg(uint typeId, address purchaseToken, uint purchaseTokenAmount, address receiver) internal {
        require(allowedTokens[purchaseToken], "SnakeEggsShop: Token not allowed");
        uint price = nftManager.getCurrentPriceBySnakeType(typeId); 
        require(price != 0, "SnakeEggsShop: Egg type not found");
        uint snakeEquivalentAmount = getSnakeEquivalentAmount(purchaseToken, purchaseTokenAmount);
        require(snakeEquivalentAmount >= price, "SnakeEggsShop: Token amount can not be lower than minimal price");
        TransferHelper.safeTransferFrom(purchaseToken, msg.sender, custodian, purchaseTokenAmount);

        Counters.increment(counter);
        uint tokenId = Counters.current(counter);
        
        nftManager.updateEggStats(tokenId, EggStats(tokenId, snakeEquivalentAmount, block.timestamp, typeId));
        snakeEggsNFT.safeMint(receiver, tokenId);

        emit BuyEgg(msg.sender, receiver, tokenId ,typeId, purchaseToken, purchaseTokenAmount, block.timestamp); 
    }

    function _buyEggsOrAirdrop(uint typeId, address[] memory receivers, bool isPurchase) internal {
        address snakeTokenCache;
        if (isPurchase) {
            snakeTokenCache = snakeToken;
            require(allowedTokens[snakeTokenCache], "SnakeEggsShop: Token not allowed");
        }
        
        uint price = nftManager.getCurrentPriceBySnakeType(typeId); 
        require(price > 0, "SnakeEggsShop: Egg type not found");

        if (isPurchase) 
            TransferHelper.safeTransferFrom(snakeTokenCache, msg.sender, custodian, receivers.length * price);
        
        for (uint256 i; i < receivers.length; i++) {
            Counters.increment(counter);
            uint tokenId = Counters.current(counter);
            
            nftManager.updateEggStats(tokenId, EggStats(tokenId, price, block.timestamp, typeId));
            snakeEggsNFT.safeMint(receivers[i], tokenId);

            if (isPurchase) {
                emit BuyEgg(msg.sender, receivers[i], tokenId, typeId, snakeTokenCache, price, block.timestamp); 
            } else {
                emit AirdropEgg(receivers[i], tokenId, typeId, block.timestamp);
            }
        }
    }
}