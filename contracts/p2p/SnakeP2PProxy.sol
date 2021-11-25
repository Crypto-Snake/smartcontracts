//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "./SnakeP2PStorage.sol";
import "../utils/Address.sol";

contract SnakeP2PProxy is SnakeP2PStorage {
    address public target;
    
    event SetTarget(address indexed newTarget);

    constructor(address _newTarget) SnakeP2PStorage() {
        isAnyNFTAllowed = true;
        _setTarget(_newTarget);
    }

    fallback() external {
        if (gasleft() <= 2300) {
            return;
        }

        address target_ = target;
        bytes memory data = msg.data;
        assembly {
            let result := delegatecall(gas(), target_, add(data, 0x20), mload(data), 0, 0)
            let size := returndatasize()
            let ptr := mload(0x40)
            returndatacopy(ptr, 0, size)
            switch result
            case 0 { revert(ptr, size) }
            default { return(ptr, size) }
        }
    }

    function setTarget(address _newTarget) external onlyOwner {
        _setTarget(_newTarget);
    }

    function _setTarget(address _newTarget) internal {
        require(Address.isContract(_newTarget), "Target not a contract");
        target = _newTarget;
        emit SetTarget(_newTarget);
    }
}