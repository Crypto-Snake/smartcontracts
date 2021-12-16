//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "../objects/Objects.sol";
import "../utils/Convertable.sol";
import "../utils/Address.sol";
import "../utils/EnumerableBytes32Set.sol";
import "../interfaces/ILockStakingRewardsPool.sol";
import "../interfaces/IBEP721Enumerable.sol";
import "../interfaces/IBEP1155.sol";

contract NFTManagerStorage is Convertable, Objects {
    using EnumerableBytes32Set for EnumerableBytes32Set.Bytes32Set;

    mapping (bytes4 => address) public logicTargets;
    EnumerableBytes32Set.Bytes32Set internal logicTargetsSet;
    
    uint public version;
    
    bytes32 public DOMAIN_SEPARATOR;
    bytes32 public APPLY_GAME_RESULTS_TYPEHASH;
    bytes32 public UPDATE_GAME_BALANCE_TYPEHASH;
    bytes32 public UPDATE_STAKE_AMOUNT_TYPEHASH;
    bytes32 public APPLY_ARTIFACT_TYPEHASH;
    
    mapping(address => uint256) public applyGameResultsNonces;
    mapping(address => uint256) public updateGameBalanceNonces;
    mapping(address => uint256) public updateStakeAmountNonces;
    mapping(address => uint256) public applyArtifactNonces;

    mapping(uint => Snake) public snakesProperties;
    mapping(uint => Egg) public eggsProperties;
    mapping(uint => Artifact) public artifactsProperties;

    mapping(uint => SnakeStats) public snakes;
    mapping(uint => EggStats) public eggs;
    mapping(uint => ArtifactStats) public artifacts;

    mapping(uint => SnakeAppliedArtifacts) public snakeAppliedArtifacts;

    mapping(address => bool) public allowedTokens;
    mapping(uint => bool) public allowedArtifacts;

    ILockStakingRewardsPool public stakingPool;
    IBEP721Enumerable public snakeEggsNFT;
    IBEP721Enumerable public snakesNFT;
    IBEP1155 public artifactsNFT;

    address public snakeEggsShop;

    uint public treshold;
    uint public baseRate = 6e17; // 60%
    uint public bonusFeedRate = 5e16; // 5%
    uint public maxRate = 115e16; // 115%

    address public custodian;

    uint public diamondAPRBonus = 5e17; // 50%
    uint public mouseTVLBonus = 1e17; // 10%
    uint public shadowSnakeRequiredTVL = 100e18;
    uint public shadowSnakeDestroyLockPeriod = 30 days;
    uint public shadowSnakeTVLMultiplier = 2;
    uint public diamondMaxAppliances = 4;

    uint public promocodeAPRBonus = 1e17; // 10%

    mapping(uint => mapping(uint => bool)) public artifactsApplied;

    function _setTarget(bytes4 sig, address target) internal {
        logicTargets[sig] = target;

        if (target != address(0)) {
            logicTargetsSet.addBytes32(bytes32(sig));
        } else {
            logicTargetsSet.removeBytes32(bytes32(sig));
        }
    }
}