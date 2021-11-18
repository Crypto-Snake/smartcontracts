//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "./Ownable.sol";
import "./Address.sol";
import "./TransferHelper.sol";
import "../interfaces/IBEP20.sol";

abstract contract RescueManager is Ownable {

    event Rescue(address indexed receiver, uint amount);
    event RescueToken(address indexed receiver, address indexed token, uint amount);

    function rescue(address payable _to, uint256 _amount) external onlyOwner {
        require(_to != address(0), "RescueManager: Cannot rescue to 0x0");
        require(_amount > 0, "RescueManager: Cannot rescue 0");

        _to.transfer(_amount);
        emit Rescue(_to, _amount);
    }

    function rescue(address _to, address _token, uint256 _amount) external onlyOwner {
        require(_to != address(0), "RescueManager: Cannot rescue to 0x0");
        require(_amount > 0, "RescueManager: Cannot rescue 0");
        require(Address.isContract(_token), "RescueManager: _token is not a contract");

        TransferHelper.safeTransfer(_token, _to, _amount);
        emit RescueToken(_to, _token, _amount);
    }
}