//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.9;

import "../interfaces/IBEP20.sol";
import "../utils/RescueManager.sol";
import "../utils/Initializable.sol";
import "../utils/ReentrancyGuard.sol";
import "../objects/FarmingObjects.sol";

contract FarmingStorage is Initializable, ReentrancyGuard, RescueManager, FarmingObjects {
    address internal _implementationAddress;
    uint public version;

    IBEP20 internal _stakingToken;

    uint internal _maxRate;
    uint internal _minRate;

    uint internal _totalSupply;
    uint internal _maxTotalSupply;

    uint internal _lockPeriod;
    
    uint internal _totalStaked;

    mapping(address => uint) public nonces;
    mapping(address => mapping(uint => FarmingInfo)) public farmingInfo;
}