//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

interface IVesting {
    function vest(address user, uint amount, uint vestingFirstPeriod, uint vestingSecondPeriod) external;
    function unvest() external returns (uint unvested);
    function unvestFor(address user) external returns (uint unvested);
}