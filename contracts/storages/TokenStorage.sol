// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "../objects/Objects.sol";
import "../interfaces/INFTManager.sol";

abstract contract TokenStorage is Objects {
    address internal _implementationAddress;

    INFTManager public nftManager;
    uint public version;

    mapping(uint256 => mapping(address => uint256)) internal _balances;
    mapping(address => mapping(address => bool)) internal _operatorApprovals;
}