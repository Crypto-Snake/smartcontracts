//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "../utils/Ownable.sol";
import "../storages/NFTManagerStorage.sol";

contract NFTManagerProxy is NFTManagerStorage {

    constructor() {
        uint chainId;
        assembly {
            chainId := chainid()
        }
        
        APPLY_GAME_RESULTS_TYPEHASH = keccak256("ApplyGameResultsBySign(uint snakeId,uint stakeAmount,uint gameBalance,address sender,uint256 nonce,uint256 deadline)");
        UPDATE_STAKE_AMOUNT_TYPEHASH = keccak256("UpdateStakeAmountBySign(uint snakeId,uint stakeAmount,bool increase,uint artifactId,address sender,uint256 nonce,uint256 deadline)");
        UPDATE_GAME_BALANCE_TYPEHASH = keccak256("UpdateGameBalanceBySign(uint snakeId,uint gameBalance,bool increase,uint artifactId,address sender,uint256 nonce,uint256 deadline)");
        APPLY_ARTIFACT_TYPEHASH = keccak256("ApplyArtifactBySign(uint snakeId,uint artifactId,uint updateAmount,address sender,uint256 nonce,uint256 deadline)");
        
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256('EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)'),
                keccak256(bytes("NFTManager")),
                keccak256(bytes("1")),
                chainId,
                address(this)
            )
        );
    }

    fallback() external {
        if (gasleft() <= 2300) {
            return;
        }

        address target = logicTargets[msg.sig];
        require(target != address(0), "target not active");

        bytes memory data = msg.data;
        assembly {
            let result := delegatecall(gas(), target, add(data, 0x20), mload(data), 0, 0)
            let size := returndatasize()
            let ptr := mload(0x40)
            returndatacopy(ptr, 0, size)
            switch result
            case 0 { revert(ptr, size) }
            default { return(ptr, size) }
        }
    }


    function addImplementationContract(address target) external onlyOwner {
        (bool success,) = target.delegatecall(abi.encodeWithSignature("initialize(address)", target));
        require(success, "setup failed");
    }

    function setTargets(string[] calldata sigsArr, address[] calldata targetsArr) external onlyOwner {
        require(sigsArr.length == targetsArr.length, "count mismatch");

        for (uint256 i = 0; i < sigsArr.length; i++) {
            _setTarget(bytes4(keccak256(abi.encodePacked(sigsArr[i]))), targetsArr[i]);
        }
    }

    function getTarget(string calldata sig) external view returns (address) {
        return logicTargets[bytes4(keccak256(abi.encodePacked(sig)))];
    }
}