//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "./Address.sol";
import "./Ownable.sol";
import "../interfaces/IRouter.sol";

abstract contract Convertable is Ownable {
    
    IRouter public router;
    address public snakeToken;
    bool public useWeightedRates;
    
    uint public constant percentPrecision = 1e18;

    mapping(address => uint) public weightedTokenSnakeExchangeRates;

    event ToggleUseWeightedRates(bool indexed useWeightedRates);
    event UpdateTokenWeightedExchangeRate(address indexed token, uint newRate);
    event UpdateRouter(address indexed router);
    event UpdateSnakeToken(address indexed token);

    function getSnakeEquivalentAmount(address purchaseToken, uint purchaseTokenAmount) public view returns (uint snakeEquivalentAmount) {
        if (!useWeightedRates) {
            address[] memory path = new address[](2);
            path[0] = purchaseToken;
            path[1] = snakeToken;
            snakeEquivalentAmount = router.getAmountsOut(purchaseTokenAmount, path)[1];
        } else {
            snakeEquivalentAmount = purchaseTokenAmount * percentPrecision / weightedTokenSnakeExchangeRates[purchaseToken];
        }
    }

    function getTokenEquivalentAmount(address token, uint snakeTokenAmount) public view returns (uint tokenEquivalentAmount) {
        if (!useWeightedRates) {
            address[] memory path = new address[](2);
            path[0] = snakeToken;
            path[1] = token;
            tokenEquivalentAmount = router.getAmountsOut(snakeTokenAmount, path)[1];
        } else {
            tokenEquivalentAmount = snakeTokenAmount * weightedTokenSnakeExchangeRates[token] / percentPrecision;
        }
    }

    function updateRouter(address _router) external onlyOwner {
        require(Address.isContract(_router), "SnakeEggsShop: _router is not a contract");
        router = IRouter(_router);
        emit UpdateRouter(_router);
    }
    
    function updateSnakeToken(address token) external onlyOwner {
        require(Address.isContract(token), "SnakeEggsShop: token is not a contract");
        snakeToken = token;
        emit UpdateSnakeToken(token);
    }
    
    function toggleUseWeightedRates() external onlyOwner {
        useWeightedRates = !useWeightedRates;
        emit ToggleUseWeightedRates(useWeightedRates);
    }

    function updateTokenWeightedExchangeRate(address token, uint rate) external onlyOwner {
        weightedTokenSnakeExchangeRates[token] = rate;
        emit UpdateTokenWeightedExchangeRate(token, rate);
    }
}