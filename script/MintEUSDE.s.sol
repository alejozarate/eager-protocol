// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Script} from "forge-std/Script.sol";

import {EagerFactory} from "src/EagerFactory.sol";
import {MockERC20} from "src/mock/ERC20.sol";
import {MockERC4626} from "src/mock/ERC4626.sol";
import {Oracle} from "src/mock/Oracle.sol";
import {EthenaEagerToken} from "src/EthenaEagerToken.sol";

contract DeployProtocolScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        MockERC20 mockToken = MockERC20(0x923588E24D5f4d373c9514ca04E2Fe219C874638);
        MockERC4626 yieldOracle = MockERC4626(0xd730952a12c77ff1dF38950B274c73D3317C6fe6);

        mockToken.approve(address(yieldOracle), 5_000_000 ether);
        yieldOracle.deposit(5_000_000, 0xF1018bEbC42c2b78B3890cfacEeBbDb983c74816);

        vm.stopBroadcast();
    }
}
