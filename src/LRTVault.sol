// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {ERC4626} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import {ILRTVault} from "src/interfaces/ILRTVault.sol";

contract LRTVault is ILRTVault, ERC4626 {
    address immutable eToken;

    error InvalidETokenCall();

    modifier onlyEToken() {
        if (msg.sender != eToken) revert InvalidETokenCall();
        _;
    }

    constructor(address _underlying, string memory _name, string memory _symbol)
        ERC4626(IERC20(_underlying))
        ERC20(_name, _symbol)
    {
        eToken = msg.sender;
    }

    function slashVault() external onlyEToken {}
}
