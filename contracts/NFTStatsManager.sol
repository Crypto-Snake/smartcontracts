//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "./NFTManagerBase.sol";

contract NFTStatsManager is NFTManagerBase {

    function initialize(address _target) external onlyOwner {
        _setTarget(this.applyGameResultsBySign.selector, _target);
        _setTarget(this.applyGameResults.selector, _target);
        _setTarget(this.updateStakeAmountBySign.selector, _target);
        _setTarget(this.updateStakeAmount.selector, _target);
        _setTarget(this.updateGameBalanceBySign.selector, _target);
        _setTarget(this.updateGameBalance.selector, _target);
        _setTarget(this.updateBonusStakeRate.selector, _target);
        _setTarget(this.updateEggStats.selector, _target);
        _setTarget(this.applyShadowSnakeBySign.selector, _target);
        
        _setTarget(this.isFeeded.selector, _target);
        _setTarget(this.isEggReadyForHatch.selector, _target);
        _setTarget(this.getEggProperties.selector, _target);
        _setTarget(this.getSnakeProperties.selector, _target);
        _setTarget(this.getEggStats.selector, _target);
        _setTarget(this.getSnakeStats.selector, _target);
        _setTarget(this.updateSnakeProperties.selector, _target);
        _setTarget(this.updateEggProperties.selector, _target);
        _setTarget(this.updateArtifactProperties.selector, _target);

        APPLY_ARTIFACT_TYPEHASH = keccak256("ApplyShadowSnakeBySign(uint snakeId,uint updateAmount,uint lockPeriod,address sender,uint256 nonce,uint256 deadline)");
    }

    function applyGameResultsBySign(uint snakeId, uint stakeAmount, uint gameBalance, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external {
        require(deadline > block.timestamp, "NFTManager: Expired");
        uint nonce = applyGameResultsNonces[msg.sender]++;
        bytes32 digest = keccak256(
            abi.encodePacked(
                '\x19\x01',
                DOMAIN_SEPARATOR,
                keccak256(abi.encode(APPLY_GAME_RESULTS_TYPEHASH, snakeId, stakeAmount, gameBalance, msg.sender, nonce, deadline))
            )
        );

        address recoveredAddress = ecrecover(digest, v, r, s);
        require(recoveredAddress != address(0) && (recoveredAddress == lowerAdmin() || recoveredAddress == owner()), 'NFTManager: INVALID_SIGNATURE');

        _updateStakeAmount(snakeId, stakeAmount, false, 0);
        _updateGameBalance(snakeId, gameBalance, 0);
    }

    function applyGameResults(uint snakeId, uint stakeAmount, uint gameBalance) external onlyOwnerOrLowerAdmin {
        _updateStakeAmount(snakeId, stakeAmount, false, 0);
        _updateGameBalance(snakeId, gameBalance, 0);
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

    function updateGameBalance(uint snakeId, uint gameBalance, uint artifactId) external onlyOwnerOrLowerAdmin {
        _updateGameBalance(snakeId, gameBalance, artifactId);
    }

    function applyShadowSnakeBySign(uint snakeId, uint updateAmount, uint lockPeriod, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external {
        require(deadline > block.timestamp, "NFTManager: Expired");
        uint nonce = applyArtifactNonces[msg.sender]++;
        bytes32 digest = keccak256(
            abi.encodePacked(
                '\x19\x01',
                DOMAIN_SEPARATOR,
                keccak256(abi.encode(APPLY_ARTIFACT_TYPEHASH, snakeId, updateAmount, lockPeriod, msg.sender, nonce, deadline))
            )
        );

        address recoveredAddress = ecrecover(digest, v, r, s);
        require(recoveredAddress != address(0) && (recoveredAddress == lowerAdmin() || recoveredAddress == owner()), 'NFTManager: INVALID_SIGNATURE');

        _applyShadowSnakeArtifact(snakeId, updateAmount, lockPeriod);
    }

    function applyShadowSnake(uint snakeId, uint updateAmount, uint lockPeriod) external onlyOwnerOrLowerAdmin {
        _applyShadowSnakeArtifact(snakeId, updateAmount, lockPeriod);
    }

    function updateBonusStakeRate(uint snakeId, uint rate) external onlyAllowedAddresses() {
        _updateBonusStakeRate(snakeId, rate, true);
    }

    function updateEggStats(uint tokenId, EggStats memory stats) external onlySnakeEggsShop() {
        require(eggs[tokenId].PurchasingTime == 0, "NFTManager: Egg with provided id already exists");
        eggs[tokenId] = stats;
        emit UpdateEggStats(tokenId, eggs[tokenId], stats);
    }
}