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
    DeVouchResolver devouchResolver;
    DeVouchResolver devouchResolverImplementation;
    TransparentUpgradeableProxy devouchResolverProxy;
    ProxyAdmin proxyAdmin;
    bytes32 schemaUID;

    event Attest(address attester);
    event Revoke(address attester);

    function setUp() public virtual {
        // setup EAS
        schemaRegistry = new SchemaRegistry();
        easContract = new EAS(ISchemaRegistry(address(schemaRegistry)));
        schemaUID = schemaRegistry.register(schema, ISchemaResolver(address(devouchResolver)), true);
        devouchResolverImplementation = new DeVouchResolver();
        proxyAdmin = ProxyAdmin(address(8));
        devouchResolverProxy = new TransparentUpgradeableProxy(
            address(devouchResolverImplementation),
            address(proxyAdmin),
            abi.encodeWithSignature("initialize(address,uint256)", address(easContract), 0)
        );
        devouchResolver = DeVouchResolver(payable(address(devouchResolverProxy)));

        vm.label(address(easContract), "EAS");
        vm.label(address(schemaRegistry), "SchemaRegistry");
        vm.label(address(devouchResolver), "DeVouchResolver");
        vm.label(address(devouchResolverImplementation), "DeVouchResolverImplementation");
        vm.label(address(devouchResolverProxy), "DeVouchResolverProxy");
        vm.label(address(proxyAdmin), "ProxyAdmin");
    }
}
