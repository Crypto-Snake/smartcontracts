//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.9;

import "./FarmingInfoStruct.sol";
import "./FarmingPoolStruct.sol";

abstract contract FarmingObjects is
    FarmingInfoStruct,
    FarmingPoolStruct
{}