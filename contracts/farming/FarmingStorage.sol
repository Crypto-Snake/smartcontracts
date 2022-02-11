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

    mapping(uint => FarmingPool) public pools;

    mapping(address => uint) public nonces;
    mapping(address => mapping(uint => FarmingInfo)) public farmingInfo;
}