// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./BEP1155Receiver.sol";

/**
 * @dev _Available since v3.1._
 */
contract BEP1155Holder is BEP1155Receiver {
    function onBEP1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onBEP1155Received.selector;
    }

    function onBEP1155BatchReceived(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onBEP1155BatchReceived.selector;
    }
}
