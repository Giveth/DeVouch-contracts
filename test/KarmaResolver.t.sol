// // SPDX License Identifier: MIT
// pragma solidity ^0.8.0;

// import "forge-std/Test.sol";
// // import "ds-test/test.sol";
// import "eas-contracts/contracts/SchemaRegistry.sol";
// import "eas-contracts/contracts/EAS.sol";
// import "eas-contracts/contracts/IEAS.sol";
// import "src/KarmaProjectResolverUpgradeable.sol";
// import "@openzeppelin-contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
// import "@openzeppelin-contracts/proxy/transparent/ProxyAdmin.sol";

// contract TestKarmaSetup is Test {
//     // eas contracts
//     SchemaRegistry schemaRegistry;
//     string schema = "string projectSource, string projectId, bool vouch, string comment";
//     EAS easContract;
//     IEAS easInterface;
//     KarmaProjectResolverUpgradable KarmaResolver;
//     KarmaProjectResolverUpgradable KarmaResolverImplementation;
//     TransparentUpgradeableProxy KarmaResolverProxy;
//     ProxyAdmin proxyAdmin;
//     bytes32 schemaUID;

//     event Attest(address attester);
//     event Revoke(address attester);

//     address owner = address(4);

//     function setUp() public virtual {
//         // setup EAS
//         schemaRegistry = new SchemaRegistry();
//         easContract = new EAS(ISchemaRegistry(address(schemaRegistry)));
//         schemaUID = schemaRegistry.register(schema, ISchemaResolver(address(KarmaResolver)), true);
//         KarmaResolverImplementation = new KarmaProjectResolverUpgradable(easContract);
//         proxyAdmin = new ProxyAdmin(owner);
//         KarmaResolverProxy = new TransparentUpgradeableProxy(
//             address(KarmaResolverImplementation),
//             address(proxyAdmin),
//             abi.encodeWithSignature("initialize(address,uint256)", address(easContract), 0.1 ether)
//         );
//         KarmaResolver = KarmaProjectResolverUpgradable(payable(address(KarmaResolverProxy)));

//         vm.label(address(easContract), "EAS");
//         vm.label(address(schemaRegistry), "SchemaRegistry");
//         vm.label(address(KarmaResolver), "KarmaResolver");
//         vm.label(address(KarmaResolverImplementation), "KarmaResolverImplementation");
//         vm.label(address(KarmaResolverProxy), "KarmaResolverProxy");
//         vm.label(address(proxyAdmin), "ProxyAdmin");
//     }

//     function testAttest() public {
//         // attest

//         bytes32 uid = easContract.attest(
//             AttestationRequest({
//                 schema: schemaUID,
//                 data: AttestationRequestData({
//                     recipient: address(0),
//                     expirationTime: NO_EXPIRATION_TIME,
//                     revocable: true,
//                     refUID: EMPTY_UID,
//                     data: abi.encode("giveth", "55", true, "this is awesome"),
//                     //  "string projectSource, string projectId, bool vouch, string comment";
//                     value: 0
//                 })
//             })
//         );
//         emit Attest(msg.sender);
//     }

//     function testUpgrade() public {
//         KarmaProjectResolverUpgradable newKarmaResolverImplementation = new KarmaProjectResolverUpgradable(easContract);
//         vm.prank(owner);
//         proxyAdmin.upgradeAndCall(
//             ITransparentUpgradeableProxy(address(KarmaResolverProxy)), address(newKarmaResolverImplementation), ""
//         );
//     }
// }
