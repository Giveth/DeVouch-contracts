// SPDX License Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {SchemaRegistry, ISchemaRegistry, ISchemaResolver} from "eas-contracts/contracts/SchemaRegistry.sol";
import {EAS, NO_EXPIRATION_TIME, EMPTY_UID} from "eas-contracts/contracts/EAS.sol";
import {IEAS, AttestationRequestData, AttestationRequest} from "eas-contracts/contracts/IEAS.sol";
import {DeVouchResolverUpgradeable} from "src/DeVouchResolverUpgradeable.sol";
import {TransparentUpgradeableProxy} from "@openzeppelin-contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import {ProxyAdmin} from "@openzeppelin-contracts/proxy/transparent/ProxyAdmin.sol";
import {Upgrades, Options} from "openzeppelin-foundry-upgrades/Upgrades.sol";

import {DevouchResolverUpgradableMockV2} from "./DevouchResolverUpgradableMockV2.sol";

contract TestSetup is Test {
    // eas contracts
    SchemaRegistry schemaRegistry;
    string schema = "string projectSource, string projectId, bool vouch, string comment";
    EAS easContract;
    IEAS easInterface;
    DeVouchResolverUpgradeable devouchResolver;
    address devouchResolverImplementation;
    // TransparentUpgradeableProxy devouchResolverProxy;
    ProxyAdmin proxyAdmin;
    bytes32 schemaUID;

    event Attest(address attester);
    event Revoke(address attester);

    address owner = address(4);

    function setUp() public virtual {
        // setup EAS
        schemaRegistry = new SchemaRegistry();
        easContract = new EAS(ISchemaRegistry(address(schemaRegistry)));

        address proxy = Upgrades.deployTransparentProxy(
            "DeVouchResolverUpgradeable.sol:DeVouchResolverUpgradeable",
            owner,
            abi.encodeCall(DeVouchResolverUpgradeable.initialize, (easContract, 0.1 ether))
        );
        devouchResolver = DeVouchResolverUpgradeable(payable(proxy));
        devouchResolverImplementation = Upgrades.getImplementationAddress(proxy);
        schemaUID = schemaRegistry.register(schema, ISchemaResolver(address(devouchResolver)), true);

        vm.label(address(easContract), "EAS");
        vm.label(address(schemaRegistry), "SchemaRegistry");
        vm.label(address(devouchResolver), "DeVouchResolver");
        vm.label(address(proxyAdmin), "ProxyAdmin");
    }

    function testAttest() public {
        // attest

        vm.expectEmit(true, true, false, false);
        emit IEAS.Attested(address(0), address(this), 0, schemaUID);
        bytes32 uid = easContract.attest{value: 0.1 ether}(
            AttestationRequest({
                schema: schemaUID,
                data: AttestationRequestData({
                    recipient: address(0),
                    expirationTime: NO_EXPIRATION_TIME,
                    revocable: true,
                    refUID: EMPTY_UID,
                    data: abi.encode("giveth", "55", true, "this is awesome"),
                    //  "string projectSource, string projectId, bool vouch, string comment";
                    value: 0.1 ether
                })
            })
        );

        assertNotEq(uid, bytes32(0));
    }

    function testUpgrade() public {
        vm.startPrank(owner);
        Upgrades.upgradeProxy(address(devouchResolver), "DevouchResolverUpgradableMockV2.sol", "");

        address newImplementation = Upgrades.getImplementationAddress(address(devouchResolver));
        assertNotEq(newImplementation, devouchResolverImplementation);
    }
}
