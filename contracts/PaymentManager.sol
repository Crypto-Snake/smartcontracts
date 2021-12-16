//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "./utils/Address.sol";
import "./utils/Allowable.sol";
import "./utils/Initializable.sol";
import "./utils/TransferHelper.sol";
import "./NFTStatsManager.sol";

contract PaymentsManager is Allowable, Initializable {

    address internal _implementationAddress;
    uint public version;

    NFTStatsManager public nftManager;
    address public stableCoin;
    bool public sendStableCoinFromContract;

    event ProcessTrophyPayment(uint indexed snakeId, uint indexed amount);
    event ProcessUnicornPayment(address indexed user, uint indexed amount);
    event UpdateNFTManager(address indexed nftManager);
    event UpdateStableCoin(address indexed stableCoin);
    event UpdateSendRewardFromContract(bool indexed value);

    function initialize(address _stableCoin, address _nftManager) external initializer {
        require(Address.isContract(_stableCoin), "PaymentsManager: _stableCoin is not a contract");
        require(Address.isContract(_nftManager), "PaymentsManager: _nftManager is not a contract");

        stableCoin = _stableCoin;
        nftManager = NFTStatsManager(_nftManager);
    }

    function processTrophyPayment(uint[] memory snakes, uint[] memory amounts) external onlyAllowedAddresses {
        require(snakes.length == amounts.length, "PaymentsManager: snakes and amounts arrays size missmatch");

        for (uint256 i = 0; i < snakes.length; i++) {
            nftManager.updateGameBalance(snakes[i], amounts[i], 5);
            emit ProcessTrophyPayment(snakes[i], amounts[i]);
        }   
    }

    function processUnicornPayment(address[] memory users, uint[] memory amounts) external onlyAllowedAddresses {
        require(users.length == amounts.length, "PaymentsManager: users and amounts arrays size missmatch");

        for (uint256 i = 0; i < users.length; i++) {
            TransferHelper.safeTransferFrom(stableCoin, msg.sender, users[i], amounts[i]);
            emit ProcessUnicornPayment(users[i], amounts[i]);
        }   
    }

    function updateNFTManager(address _nftManager) external onlyOwner {
        require(Address.isContract(_nftManager), "PaymentsManager: _nftManager is not a contract");
        nftManager = NFTStatsManager(_nftManager);
        emit UpdateNFTManager(_nftManager);
    }

    function updateStableCoin(address _stableCoin) external onlyOwner {
        require(Address.isContract(_stableCoin), "PaymentsManager: _stableCoin is not a contract");
        stableCoin = _stableCoin;
        emit UpdateStableCoin(_stableCoin);
    }

    function updateSendRewardFromContract(bool value) external onlyOwner {
        sendStableCoinFromContract = value;
        emit UpdateSendRewardFromContract(value);
    }
}