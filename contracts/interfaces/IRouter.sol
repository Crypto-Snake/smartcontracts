//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

interface IRouter {
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
}