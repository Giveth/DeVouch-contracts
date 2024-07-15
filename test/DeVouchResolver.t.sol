// SPDX License Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "ds-test/test.sol";
import "eas-contracts/contracts/SchemaRegistry.sol";
import "eas-contracts/contracts/EAS.sol";
import "eas-contracts/contracts/IEAS.sol";
import "eas-contracts/contracts/resolver/SchemaResolver.sol";
import "src/DeVouchResolver.sol";

contract TestSetup is Test {
    // eas contracts
    SchemaRegistry schemaRegistry;
    EAS easContract;
    IEAS easInterface;
    DeVouchResolver devouchResolver;

    event Attest(address attester);
    event Revoke(address attester);

    function setUp() public virtual {
        // setup EAS
        schemaRegistry = new SchemaRegistry();
        easContract = new EAS(ISchemaRegistry(address(schemaRegistry)));
        devouchResolver = new DeVouchResolver(IEAS(address(easContract)), address(this));
        schemaUID = schemaRegistry.register(schema, ISchemaResolver(address(devouchResolver)), true);
    
    }
}