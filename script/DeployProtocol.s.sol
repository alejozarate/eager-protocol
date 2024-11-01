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

        EagerFactory factory = new EagerFactory();
        MockERC20 insuredToken = new MockERC20("usde", "usde");
        MockERC20 lrtToken = new MockERC20("LRTToken", "LRTToken");
        Oracle oracle = new Oracle();

        MockERC4626 yieldOracle = new MockERC4626(address(insuredToken), "eusde", "eusde");

        EthenaEagerToken(
            factory.deployEagerPair(address(insuredToken), address(lrtToken), address(yieldOracle), address(oracle))
        );

        vm.stopBroadcast();
    }
}
