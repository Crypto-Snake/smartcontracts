//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "./interfaces/IBEP20.sol";
import "./interfaces/IVesting.sol";
import "./utils/Pausable.sol";
import "./utils/TransferHelper.sol";
import "./utils/RescueManager.sol";

contract SnakeVesting is IVesting, Ownable, Pausable, RescueManager { 

    IBEP20 public immutable vestingToken;

    struct VestingInfo {
        uint vestingAmount;
        uint unvestedAmount;
        uint vestingStart;
        uint vestingReleaseStartDate;
        uint vestingEnd;
        uint vestingSecondPeriod;
    }

    mapping (address => uint) public vestingNonces;
    mapping (address => mapping (uint => VestingInfo)) public vestingInfos;
    mapping (address => bool) public vesters;

    bool public canAnyoneUnvest;

    event UpdateVesters(address vester, bool isActive);
    event Vest(address indexed user, uint vestNonece, uint amount, uint indexed vestingFirstPeriod, uint vestingSecondPeriod, uint vestingReleaseStartDate, uint vestingEnd);
    event Unvest(address indexed user, uint amount);
    event ToggleCanAnyoneUnvest(bool indexed canAnyoneUnvest);

    constructor(address vestingTokenAddress) {
        require(Address.isContract(vestingTokenAddress), "SnakeVesting: Not a contract");
        vestingToken = IBEP20(vestingTokenAddress);
    }
    
    function vest(address user, uint amount, uint vestingFirstPeriod, uint vestingSecondPeriod) override external whenNotPaused { 
        require (msg.sender == owner() || vesters[msg.sender], "SnakeVesting::vest: Not allowed");
        require(user != address(0), "SnakeVesting::vest: Vest to the zero address");
        uint nonce = ++vestingNonces[user];

        vestingInfos[user][nonce].vestingAmount = amount;
        vestingInfos[user][nonce].vestingStart = block.timestamp;
        vestingInfos[user][nonce].vestingSecondPeriod = vestingSecondPeriod;
        uint vestingReleaseStartDate = block.timestamp + vestingFirstPeriod;
        uint vestingEnd = vestingReleaseStartDate + vestingSecondPeriod;
        vestingInfos[user][nonce].vestingReleaseStartDate = vestingReleaseStartDate;
        vestingInfos[user][nonce].vestingEnd = vestingEnd;
        emit Vest(user, nonce, amount, vestingFirstPeriod, vestingSecondPeriod, vestingReleaseStartDate, vestingEnd);
    }

    function unvest() external override whenNotPaused returns (uint unvested) {
        return _unvest(msg.sender);
    }

    function unvestFor(address user) external override whenNotPaused returns (uint unvested) {
        require(canAnyoneUnvest || vesters[msg.sender], "SnakeVesting: Not allowed");
        return _unvest(user);
    }

    function unvestForBatch(address[] memory users) external whenNotPaused returns (uint unvested) {
        require(canAnyoneUnvest || vesters[msg.sender], "SnakeVesting: Not allowed");
        uint length = users.length;
        for (uint i = 0; i < length; i++) {
            unvested += _unvest(users[i]);
        }
    }

    function _unvest(address user) internal returns (uint unvested) {
        uint nonce = vestingNonces[user]; 
        require (nonce > 0, "SnakeVesting: No vested amount");
        for (uint i = 1; i <= nonce; i++) {
            VestingInfo memory vestingInfo = vestingInfos[user][i];
            if (vestingInfo.vestingAmount == vestingInfo.unvestedAmount) continue;
            if (vestingInfo.vestingReleaseStartDate > block.timestamp) continue;
            uint toUnvest;
            if (vestingInfo.vestingSecondPeriod != 0) {
                toUnvest = (block.timestamp - vestingInfo.vestingReleaseStartDate) * vestingInfo.vestingAmount / vestingInfo.vestingSecondPeriod;
                if (toUnvest > vestingInfo.vestingAmount) {
                    toUnvest = vestingInfo.vestingAmount;
                } 
            } else {
                toUnvest = vestingInfo.vestingAmount;
            }
            uint totalUnvestedForNonce = toUnvest;
            toUnvest -= vestingInfo.unvestedAmount;
            unvested += toUnvest;
            vestingInfos[user][i].unvestedAmount = totalUnvestedForNonce;
        }
        require(unvested > 0, "SnakeVesting: Unvest amount is zero");
        TransferHelper.safeTransfer(address(vestingToken), user, unvested);
        emit Unvest(user, unvested);
    }

    function availableForUnvesting(address user) external view returns (uint unvestAmount) {
        uint nonce = vestingNonces[user];
        if (nonce == 0) return 0;
        for (uint i = 1; i <= nonce; i++) {
            VestingInfo memory vestingInfo = vestingInfos[user][i];
            if (vestingInfo.vestingAmount == vestingInfo.unvestedAmount) continue;
            if (vestingInfo.vestingReleaseStartDate > block.timestamp) continue;
            uint toUnvest;
            if (vestingInfo.vestingSecondPeriod != 0) {
                toUnvest = (block.timestamp - vestingInfo.vestingReleaseStartDate) * vestingInfo.vestingAmount / vestingInfo.vestingSecondPeriod;
                if (toUnvest > vestingInfo.vestingAmount) {
                    toUnvest = vestingInfo.vestingAmount;
                } 
            } else {
                toUnvest = vestingInfo.vestingAmount;
            }
            toUnvest -= vestingInfo.unvestedAmount;
            unvestAmount += toUnvest;
        }
    }

    function userUnvested(address user) external view returns (uint totalUnvested) {
        uint nonce = vestingNonces[user];
        if (nonce == 0) return 0;
        for (uint i = 1; i <= nonce; i++) {
            VestingInfo memory vestingInfo = vestingInfos[user][i];
            if (vestingInfo.vestingReleaseStartDate > block.timestamp) continue;
            totalUnvested += vestingInfo.unvestedAmount;
        }
    }


    function userVestedUnclaimed(address user) external view returns (uint unclaimed) {
        uint nonce = vestingNonces[user];
        if (nonce == 0) return 0;
        for (uint i = 1; i <= nonce; i++) {
            VestingInfo memory vestingInfo = vestingInfos[user][i];
            if (vestingInfo.vestingAmount == vestingInfo.unvestedAmount) continue;
            unclaimed += (vestingInfo.vestingAmount - vestingInfo.unvestedAmount);
        }
    }

    function userTotalVested(address user) external view returns (uint totalVested) {
        uint nonce = vestingNonces[user];
        if (nonce == 0) return 0;
        for (uint i = 1; i <= nonce; i++) {
            totalVested += vestingInfos[user][i].vestingAmount;
        }
    }

    function updateVesters(address vester, bool isActive) external onlyOwner { 
        require(vester != address(0), "SnakeVesting::updateVesters: Zero address");
        vesters[vester] = isActive;
        emit UpdateVesters(vester, isActive);
    }

    function toggleCanAnyoneUnvest() external onlyOwner { 
        canAnyoneUnvest = !canAnyoneUnvest;
        emit ToggleCanAnyoneUnvest(canAnyoneUnvest);
    }
}