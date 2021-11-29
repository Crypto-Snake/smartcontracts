//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "./Ownable.sol";

abstract contract Allowable is Ownable {
    address private _lowerAdmin;
    mapping(address => bool) public allowedAddresses;

    function lowerAdmin() public view returns (address) {
        return _lowerAdmin;
    }

    modifier onlyAllowedAddresses {
        require(allowedAddresses[msg.sender] || msg.sender == owner(), "Allowable: Not allowed address");
        _;
    }

    modifier onlyOwnerOrLowerAdmin {
        require(msg.sender == owner() || msg.sender == lowerAdmin(), "Allowable: Not allowed address");
        _;
    }

    function updateAllowedAddresses(address _address, bool _value) external virtual onlyOwner {
        allowedAddresses[_address] = _value;
    }

    function updateLowerAdmin(address _address) external virtual onlyOwner {
        _lowerAdmin = _address;
    }
}

