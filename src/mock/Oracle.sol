// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract Oracle is Ownable {
    constructor() Ownable(msg.sender) {}

    int256 public answer;

    function latestAnswer() external pure returns (int256 _answer) {
        return 100000000;
    }

    function decimals() external pure returns (uint8) {
        return 8;
    }

    function setLatestAnswer(int256 _answer) external onlyOwner {
        answer = _answer;
    }
}
