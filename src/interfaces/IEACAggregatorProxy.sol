// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

interface IEACAggregatorProxy {
    function latestAnswer() external view returns (int256 answer);
    function decimals() external view returns (uint8);
}
