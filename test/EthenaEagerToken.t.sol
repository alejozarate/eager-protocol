// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Test} from "forge-std/Test.sol";
import {EagerFactory} from "src/EagerFactory.sol";
import {EthenaEagerToken} from "src/EthenaEagerToken.sol";
import {MockERC20} from "src/mock/ERC20.sol";
import {MockERC4626} from "src/mock/ERC4626.sol";
import {Oracle} from "src/mock/Oracle.sol";
import {LRTVault} from "src/LRTVault.sol";

contract EthenaEagerTokenTest is Test {
    function test_successful() public {
        address owner = makeAddr("owner");
        EagerFactory factory = new EagerFactory();
        MockERC20 insuredToken = new MockERC20("usde", "usde");
        MockERC20 lrtToken = new MockERC20("LRTToken", "LRTToken");
        Oracle oracle = new Oracle();

        MockERC4626 yieldOracle = new MockERC4626(address(insuredToken), "eusde", "eusde");

        EthenaEagerToken eToken = EthenaEagerToken(
            factory.deployEagerPair(address(insuredToken), address(lrtToken), address(yieldOracle), address(oracle))
        );

        LRTVault lrtVault = LRTVault(address(eToken.lrtVault()));

        insuredToken.approve(address(eToken), 1 ether);
        eToken.deposit(1 ether, address(this));

        eToken.approve(address(eToken), 1 ether);
        eToken.redeem(1 ether, address(this), address(this));

        lrtToken.approve(address(lrtVault), 1 ether);
        lrtVault.deposit(1 ether, address(this));
    }
}
