// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IBEP1155.sol";

/**
 * @dev Interface of the optional BEP1155MetadataExtension interface, as defined
 * in the https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[EIP].
 *
 * _Available since v3.1._
 */
interface IBEP1155MetadataURI is IBEP1155 {
    /**
     * @dev Returns the URI for token type `id`.
     *
     * If the `\{id\}` substring is present in the URI, it must be replaced by
     * clients with the actual token type ID.
     */
    function uri(uint256 id) external view returns (string memory);
}
