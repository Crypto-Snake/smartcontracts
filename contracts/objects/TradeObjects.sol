//SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.9;

import "./TradeSingleStruct.sol";
import "./TradeMultiStruct.sol";


abstract contract TradeObjects is
    TradeSingleStruct,
    TradeMultiStruct
{}