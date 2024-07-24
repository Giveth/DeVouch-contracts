// SPDX License Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
// import "ds-test/test.sol";
import "eas-contracts/contracts/SchemaRegistry.sol";
import "eas-contracts/contracts/EAS.sol";
import "eas-contracts/contracts/IEAS.sol";
import "src/DeVouchResolverUpgradeable.sol";
import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";

contract TestSetup is Test {
    // eas contracts
    SchemaRegistry schemaRegistry;
    string schema = "string projectSource, string projectId, bool vouch, string comment";
    EAS easContract;
    IEAS easInterface;
    DeVouchResolverUpgradable devouchResolver;
    DeVouchResolverUpgradable devouchResolverImplementation;
    TransparentUpgradeableProxy devouchResolverProxy;
    ProxyAdmin proxyAdmin;
    bytes32 schemaUID;

    event Attest(address attester);
    event Revoke(address attester);

    address owner = address(4);

    function setUp() public virtual {
        // setup EAS
        schemaRegistry = new SchemaRegistry();
        easContract = new EAS(ISchemaRegistry(address(schemaRegistry)));
        schemaUID = schemaRegistry.register(schema, ISchemaResolver(address(devouchResolver)), true);
        devouchResolverImplementation = new DeVouchResolverUpgradable();
        proxyAdmin = new ProxyAdmin(owner);
        devouchResolverProxy = new TransparentUpgradeableProxy(
            address(devouchResolverImplementation),
            address(proxyAdmin),
            abi.encodeWithSignature("initialize(address,uint256)", address(easContract), 0.1 ether)
        );
        devouchResolver = DeVouchResolverUpgradable(payable(address(devouchResolverProxy)));

        vm.label(address(easContract), "EAS");
        vm.label(address(schemaRegistry), "SchemaRegistry");
        vm.label(address(devouchResolver), "DeVouchResolver");
        vm.label(address(devouchResolverImplementation), "DeVouchResolverImplementation");
        vm.label(address(devouchResolverProxy), "DeVouchResolverProxy");
        vm.label(address(proxyAdmin), "ProxyAdmin");
    }

    function testAttest() public {
        // attest

        bytes32 uid = easContract.attest(
            AttestationRequest({
                schema: schemaUID,
                data: AttestationRequestData({
                    recipient: address(0),
                    expirationTime: NO_EXPIRATION_TIME,
                    revocable: true,
                    refUID: EMPTY_UID,
                    data: abi.encode("giveth", "55", true, "this is awesome"),
                    //  "string projectSource, string projectId, bool vouch, string comment";
                    value: 0
                })
            })
        );
        emit Attest(msg.sender);
    }

    function testUpgrade() public {
        DeVouchResolverUpgradable newDeVouchResolverImplementation = new DeVouchResolverUpgradable();
        vm.prank(owner);
        proxyAdmin.upgradeAndCall(
            ITransparentUpgradeableProxy(address(devouchResolverProxy)),
            address(newDeVouchResolverImplementation),
            ""
        );
    }
}
