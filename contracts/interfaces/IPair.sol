//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "./IBEP20.sol";

interface IPair is IBEP20 {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function token0() external view returns (address);
    function token1() external view returns (address);
}