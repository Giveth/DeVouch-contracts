// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {EAS} from "eas-contracts/contracts/EAS.sol";
import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";
import {DeVouchResolverUpgradeable} from "src/DeVouchResolverUpgradeable.sol";

contract UpgradeResolverScript is Script {
    function setUp() public {}

    function run() public {
        address proxy = vm.envAddress("PROXY_ADDRESS");
        console.log("Proxy: %s", proxy);

        vm.startBroadcast();

        Upgrades.upgradeProxy(proxy, "DeVouchResolverUpgradeableV2.sol", "");

        console.log("Resolver: %s", proxy);
        console.log("Implementation: %s", Upgrades.getImplementationAddress(proxy));
        console.log("Proxy Admin: %s", Upgrades.getAdminAddress(proxy));

        vm.stopBroadcast();
    }
}
