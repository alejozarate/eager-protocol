// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

import {IERC20Extended} from "src/interfaces/IERC20Extended.sol";

import {EthenaEagerToken} from "src/EthenaEagerToken.sol";
import {LRTVault} from "src/LRTVault.sol";

contract EagerFactory is Ownable {
    constructor() Ownable(msg.sender) {}

    function deployEagerPair(address _insuredToken, address _lrtToken, address _insuredYieldOracle, address _pegOracle)
        external
        onlyOwner
    {
        IERC20Extended insuredToken = IERC20Extended(_insuredToken);

        new EthenaEagerToken{salt: keccak256(abi.encodePacked(msg.sender, block.timestamp))}(
            _insuredToken,
            string(abi.encodePacked("Eager ", insuredToken.name())),
            string(abi.encodePacked("e", insuredToken.symbol())),
            _insuredYieldOracle,
            _pegOracle,
            _lrtToken
        );
    }
}
