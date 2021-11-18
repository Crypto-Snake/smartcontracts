//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "./Ownable.sol";

abstract contract Allowable is Ownable {
    mapping(address => bool) public allowedAddresses;

    modifier onlyAllowedAddresses {
        require(allowedAddresses[msg.sender] || msg.sender == owner(), "Allowable: Not allowed address");
        _;
    }

    function updateAllowedAddresses(address _address, bool _value) external virtual onlyOwner {
        allowedAddresses[_address] = _value;
    }
}

