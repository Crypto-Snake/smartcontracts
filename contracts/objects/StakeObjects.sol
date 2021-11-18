//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.9;

import "./TokenStakeInfoStruct.sol";
import "./StakeInfoStruct.sol";

abstract contract StakeObjects is
    TokenStakeInfoStruct,
    StakeInfoStruct
{}
