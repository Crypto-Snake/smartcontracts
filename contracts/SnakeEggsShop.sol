//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "./NFTShop.sol";
import "./utils/Ownable.sol";
import "./utils/Counters.sol";

contract SnakeEggsShop is NFTShop {
    using Counters for Counters.Counter;

    IBEP721Enumerable public snakeEggsNFT;

    Counters.Counter public counter;

    event BuyEgg(address indexed buyer, uint eggId, uint typeId, address indexed token, uint indexed purchaseAmount, uint purchaseTime);

    constructor(address _router, address _snakeEggsNFT, address _nftManager, address _snakeToken, address _custodian) { 
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
        require(allowedTokens[purchaseToken], "SnakeEggsShop: Token not allowed");
        uint price = nftManager.getEggTypeProperties(typeId).Price; 
        require(price != 0, "SnakeEggsShop: Egg type not found");
        uint snakeEquivalentAmount = getSnakeEquivalentAmount(purchaseToken, purchaseTokenAmount);
        require(snakeEquivalentAmount >= price, "SnakeEggsShop: Token amount can't be lower than minimal price");
        TransferHelper.safeTransferFrom(purchaseToken, msg.sender, custodian, purchaseTokenAmount);

        Counters.increment(counter);
        uint tokenId = Counters.current(counter);
        
        nftManager.updateEggStats(tokenId, EggStats(tokenId, snakeEquivalentAmount, block.timestamp, typeId));
        snakeEggsNFT.safeMint(msg.sender, tokenId);

        emit BuyEgg(msg.sender, tokenId ,typeId, purchaseToken, purchaseTokenAmount, block.timestamp); 
    }

    function updateSnakeEggsNFT(address _snakeEggsNFT) external onlyOwner {
        require(Address.isContract(_snakeEggsNFT), "BaseTokenStorage: _snakeEggsNFT is not a contract");
        snakeEggsNFT = IBEP721Enumerable(_snakeEggsNFT);
    }
}