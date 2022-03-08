//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "./NFTManagerBase.sol";
import "./utils/TransferHelper.sol";

contract NFTStatsManager is NFTManagerBase {

    event ApplyGameResults(uint indexed snakeId, uint stakeAmount, uint gameBalance, uint timestamp);

    function initialize(address _target) external onlyOwner {
        _setTarget(this.applyMultipleGameResultsBySign.selector, _target);
        _setTarget(this.applyMultipleGameResults.selector, _target);
        _setTarget(this.updateStakeAmountBySign.selector, _target);
        _setTarget(this.updateStakeAmount.selector, _target);
        _setTarget(this.updateGameBalanceBySign.selector, _target);
        _setTarget(this.updateGameBalance.selector, _target);
        _setTarget(this.updateBonusStakeRate.selector, _target);
        _setTarget(this.updateEggStats.selector, _target);
        
        _setTarget(this.isFeeded.selector, _target);
        _setTarget(this.isEggReadyForHatch.selector, _target);
        _setTarget(this.getEggProperties.selector, _target);
        _setTarget(this.getSnakeProperties.selector, _target);
        _setTarget(this.getEggTypeProperties.selector, _target);
        _setTarget(this.getSnakeTypeProperties.selector, _target);
        _setTarget(this.getEggStats.selector, _target);
        _setTarget(this.getSnakeStats.selector, _target);
        _setTarget(this.sleepingStartTime.selector, _target);
        _setTarget(this.applyMultipleGameResultsNonces.selector, _target);
        _setTarget(this.APPLY_MULTIPLE_GAME_RESULTS_TYPEHASH.selector, _target);

        _APPLY_MULTIPLE_GAME_RESULTS_TYPEHASH = keccak256("ApplyMultipleGameResultsBySign(uint[] snakeIds,uint[] stakeAmounts,uint[] gameBalances,bool[] increase,bool[] toWallet,address sender,uint256 nonce,uint256 deadline)");
    }

    function applyMultipleGameResultsBySign(uint[] memory snakeIds, uint[] memory stakeAmounts, uint[] memory gameBalances, bool[] memory increase, bool[] memory toWallet, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external {
        require(snakeIds.length == stakeAmounts.length 
        && snakeIds.length == gameBalances.length 
        && snakeIds.length == toWallet.length 
        && snakeIds.length == increase.length, 
        "NFTManager: Array length missmatch");
        require(deadline > block.timestamp, "NFTManager: Expired");
        uint nonce = applyMultipleGameResultsNonces(msg.sender);
        _applyMultipleGameResultsNonces[msg.sender] += 1;

        bytes32 digest = keccak256(
            abi.encodePacked(
                '\x19\x01',
                DOMAIN_SEPARATOR,
                keccak256(abi.encode(APPLY_MULTIPLE_GAME_RESULTS_TYPEHASH(), 
                keccak256(abi.encodePacked(snakeIds)), 
                keccak256(abi.encodePacked(stakeAmounts)), 
                keccak256(abi.encodePacked(gameBalances)),
                keccak256(abi.encodePacked(increase)),
                keccak256(abi.encodePacked(toWallet)), msg.sender, nonce, deadline))
            )
        );

        address recoveredAddress = ecrecover(digest, v, r, s);
        require(recoveredAddress != address(0) && (recoveredAddress == lowerAdmin() || recoveredAddress == owner()), 'NFTManager: INVALID_SIGNATURE');

        _applyMultipleGameResults(snakeIds, stakeAmounts, gameBalances, increase, toWallet);
    }

    function applyMultipleGameResults(uint[] memory snakeIds, uint[] memory stakeAmounts, uint[] memory gameBalances, bool[] memory increase, bool[] memory toWallet) external onlyOwnerOrLowerAdmin {
        require(snakeIds.length == stakeAmounts.length && snakeIds.length == gameBalances.length && snakeIds.length == toWallet.length, "NFTManager: Array length missmatch");

        _applyMultipleGameResults(snakeIds, stakeAmounts, gameBalances, increase, toWallet);
    }

    function updateStakeAmountBySign(uint snakeId, uint stakeAmount, bool increase, uint artifactId, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external {
        require(deadline > block.timestamp, "NFTManager: Expired");
        uint nonce = updateStakeAmountNonces[msg.sender]++;
        bytes32 digest = keccak256(
            abi.encodePacked(
                '\x19\x01',
                DOMAIN_SEPARATOR,
                keccak256(abi.encode(UPDATE_STAKE_AMOUNT_TYPEHASH, snakeId, stakeAmount, increase, artifactId, msg.sender, nonce, deadline))
            )
        );

        address recoveredAddress = ecrecover(digest, v, r, s);
        require(recoveredAddress != address(0) && (recoveredAddress == lowerAdmin() || recoveredAddress == owner()), 'NFTManager: INVALID_SIGNATURE');

        _updateStakeAmount(snakeId, stakeAmount, increase, artifactId);
    }

    function updateStakeAmount(uint snakeId, uint stakeAmount, bool increase, uint artifactId) external onlyOwnerOrLowerAdmin {
        _updateStakeAmount(snakeId, stakeAmount, increase, artifactId);
    }

    function updateGameBalanceBySign(uint snakeId, uint gameBalance, uint artifactId, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external {
        require(deadline > block.timestamp, "NFTManager: Expired");
        uint nonce = updateGameBalanceNonces[msg.sender]++;
        bytes32 digest = keccak256(
            abi.encodePacked(
                '\x19\x01',
                DOMAIN_SEPARATOR,
                keccak256(abi.encode(UPDATE_GAME_BALANCE_TYPEHASH, snakeId, gameBalance, artifactId, msg.sender, nonce, deadline))
            )
        );

        address recoveredAddress = ecrecover(digest, v, r, s);
        require(recoveredAddress != address(0) && (recoveredAddress == lowerAdmin() || recoveredAddress == owner()), 'NFTManager: INVALID_SIGNATURE');

        _updateGameBalance(snakeId, gameBalance, artifactId);
    }

    function updateGameBalance(uint snakeId, uint gameBalance, uint artifactId) external onlyAllowedAddresses {
        _updateGameBalance(snakeId, gameBalance, artifactId);
    }

    function updateBonusStakeRate(uint snakeId, uint rate) external onlyAllowedAddresses {
        _updateBonusStakeRate(snakeId, rate, true);
    }

    function updateEggStats(uint tokenId, EggStats memory stats) external onlySnakeEggsShop {
        require(eggs[tokenId].PurchasingTime == 0, "NFTManager: Egg with provided id already exists");
        eggs[tokenId] = stats;
        emit UpdateEggStats(tokenId, eggs[tokenId], stats);
    }

    //change stakeAmounts to int
    function _applyMultipleGameResults(uint[] memory snakeIds, uint[] memory stakeAmounts, uint[] memory gameBalances, bool[] memory increase, bool[] memory toWallet) internal {
        for (uint256 i = 0; i < snakeIds.length; i++) {
            if(stakeAmounts[i] != 0) {
                _updateStakeAmount(snakeIds[i], stakeAmounts[i], increase[i], 0);
            }

            if(gameBalances[i] != 0) {
                if(toWallet[i]) { 
                    TransferHelper.safeTransfer(snakeToken, msg.sender, gameBalances[i]);
                } else {
                    _updateGameBalance(snakeIds[i], gameBalances[i], 0);
                }
            }

            emit ApplyGameResults(snakeIds[i], stakeAmounts[i], gameBalances[i], block.timestamp);
        }
    }
}