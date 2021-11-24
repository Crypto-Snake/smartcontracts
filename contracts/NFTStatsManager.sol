//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "./NFTManagerBase.sol";

contract NFTStatsManager is NFTManagerBase {

    event ApplyArtifact(uint indexed snakeId, uint indexed artifactId, address indexed user, uint applyingTime);

    function initialize(address _target) external onlyOwner {
        _setTarget(this.applyGameResultsBySign.selector, _target);
        _setTarget(this.applyGameResults.selector, _target);
        _setTarget(this.updateStakeAmountBySign.selector, _target);
        _setTarget(this.updateStakeAmount.selector, _target);
        _setTarget(this.updateGameBalanceBySign.selector, _target);
        _setTarget(this.updateGameBalance.selector, _target);
        _setTarget(this.updateStakeRate.selector, _target);
        _setTarget(this.updateEggStats.selector, _target);
        _setTarget(this.applyArtifact.selector, _target);
        
        _setTarget(this.isFeeded.selector, _target);
        _setTarget(this.canApplyArtifact.selector, _target);
        _setTarget(this.isEggReadyForHatch.selector, _target);
        _setTarget(this.getArtifactProperties.selector, _target);
        _setTarget(this.getEggProperties.selector, _target);
        _setTarget(this.getSnakeProperties.selector, _target);
        _setTarget(this.getEggStats.selector, _target);
        _setTarget(this.getSnakeStats.selector, _target);
        _setTarget(this.updateSnakeProperties.selector, _target);
        _setTarget(this.updateEggProperties.selector, _target);
        _setTarget(this.updateArtifactProperties.selector, _target);
    }

    function applyGameResultsBySign(uint snakeId, uint stakeAmount, uint gameBalance, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external {
        uint nonce = applyGameResultsNonces[msg.sender]++;
        bytes32 digest = keccak256(
            abi.encodePacked(
                '\x19\x01',
                DOMAIN_SEPARATOR,
                keccak256(abi.encode(APPLY_GAME_RESULTS_TYPEHASH, snakeId, stakeAmount, gameBalance, nonce, deadline))
            )
        );

        address recoveredAddress = ecrecover(digest, v, r, s);
        require(recoveredAddress != address(0) && recoveredAddress == owner(), 'NFTManager: INVALID_SIGNATURE');

        _updateStakeAmount(snakeId, stakeAmount, false);
        _updateGameBalance(snakeId, gameBalance);
    }

    function applyGameResults(uint snakeId, uint stakeAmount, uint gameBalance) external onlyOwner {
        _updateStakeAmount(snakeId, stakeAmount, false);
        _updateGameBalance(snakeId, gameBalance);
    }

    function updateStakeAmountBySign(uint snakeId, uint stakeAmount, bool increase, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external {
        uint nonce = updateStakeAmountNonces[msg.sender]++;
        bytes32 digest = keccak256(
            abi.encodePacked(
                '\x19\x01',
                DOMAIN_SEPARATOR,
                keccak256(abi.encode(UPDATE_STAKE_AMOUNT_TYPEHASH, snakeId, stakeAmount, increase, nonce, deadline))
            )
        );

        address recoveredAddress = ecrecover(digest, v, r, s);
        require(recoveredAddress != address(0) && recoveredAddress == owner(), 'NFTManager: INVALID_SIGNATURE');

        _updateStakeAmount(snakeId, stakeAmount, increase);
    }

    function updateStakeAmount(uint snakeId, uint stakeAmount, bool increase) external onlyOwner {
        _updateStakeAmount(snakeId, stakeAmount, increase);
    }

    function updateGameBalanceBySign(uint snakeId, uint gameBalance, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external {
        uint nonce = updateGameBalanceNonces[msg.sender]++;
        bytes32 digest = keccak256(
            abi.encodePacked(
                '\x19\x01',
                DOMAIN_SEPARATOR,
                keccak256(abi.encode(UPDATE_GAME_BALANCE_TYPEHASH, snakeId, gameBalance, nonce, deadline))
            )
        );

        address recoveredAddress = ecrecover(digest, v, r, s);
        require(recoveredAddress != address(0) && recoveredAddress == owner(), 'NFTManager: INVALID_SIGNATURE');

        _updateGameBalance(snakeId, gameBalance);
    }

    function updateGameBalance(uint snakeId, uint gameBalance) external onlyOwner {
        _updateGameBalance(snakeId, gameBalance);
    }

    function updateStakeRate(uint snakeId, uint rate) external onlyAllowedAddresses() {
        _updateStakeRate(snakeId, rate, true);
    }

    function updateEggStats(uint tokenId, EggStats memory stats) external onlySnakeEggsShop() {
        require(eggs[tokenId].PurchasingTime == 0, "NFTManager: Egg with provided id already exists");
        eggs[tokenId] = stats;
        emit UpdateEggStats(tokenId, eggs[tokenId], stats);
    }

    function applyArtifact(uint snakeId, uint artifactId) external onlySnakeOwner(snakeId) onlyArtifactOwner(artifactId) {
        require(allowedArtifacts[artifactId], "NFTManager: Not allowed to apply");

        if(artifactId == 2) {
            require(snakeAppliedArtifacts[snakeId].TimesDiamondApplied <= 4, "Cannot apply diamond more times for one snake");
            _applyDiamondArtifact(snakeId);
        } else if(artifactId == 4) {
            _applyMouseArtifact(snakeId);
        } else if(artifactId == 6) {
            _applyShadowSnakeArtifact(snakeId);
        } else if(artifactId == 8) {
            require(!snakeAppliedArtifacts[snakeId].IsSnakeHunterApplied, "Cannot apply more than one snake hunter for one snake");
            snakeAppliedArtifacts[snakeId].IsSnakeHunterApplied = true;
        } else if(artifactId == 9) {
            require(!snakeAppliedArtifacts[snakeId].IsSnakeCharmerApplied, "Cannot apply more than one snake charmer for one snake");
            snakeAppliedArtifacts[snakeId].IsSnakeCharmerApplied = true;
        } else if(artifactId == 10) {
            stakingPool.getRewardFor(snakeId, msg.sender, false);
        }

        artifactsNFT.burn(msg.sender, artifactId, 1);
        
        emit ApplyArtifact(snakeId, artifactId, msg.sender, block.timestamp);
    }
    
    function _applyDiamondArtifact(uint snakeId) internal {
        _updateStakeRate(snakeId, diamondAPRBonus, true);
    }

    function _applyMouseArtifact(uint snakeId) internal {
        uint updateAmount = (snakes[snakeId].StakeAmount * mouseTVLBonus) / percentPrecision;
        _updateStakeAmount(snakeId, updateAmount, true);
    }

    function _applyShadowSnakeArtifact(uint snakeId) internal {
        SnakeStats memory stats = snakes[snakeId];
        require(stats.Type == 1, "NFTManager: Can apply this artifact only to dasypeltis");
        require(stats.StakeAmount >= shadowSnakeRequiredTVL, "NFTManager: Snake`s TVL less than required");

        snakes[snakeId].DestroyLock = block.timestamp + shadowSnakeDestroyLockPeriod;
        snakes[snakeId].StakeAmount = shadowSnakeTVLMultiplier * stats.StakeAmount;
    }
}