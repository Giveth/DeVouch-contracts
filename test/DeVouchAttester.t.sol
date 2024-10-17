// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {Vm} from "forge-std/Vm.sol";
import {SchemaRegistry, ISchemaRegistry} from "eas-contracts/contracts/SchemaRegistry.sol";
import {EAS, NO_EXPIRATION_TIME, EMPTY_UID} from "eas-contracts/contracts/EAS.sol";
import {IEAS, AttestationRequestData, AttestationRequest, MultiAttestationRequest} from "eas-contracts/contracts/IEAS.sol";
import {ISchemaResolver} from "eas-contracts/contracts/resolver/ISchemaResolver.sol";
import {DeVouchAttester} from "../src/DeVouchAttester.sol";

contract DevouchAttesterTest is Test {
    SchemaRegistry schemaRegistry;
    string schema = "string projectSource, string projectId, bool vouch, string comment";
    EAS easContract;
    IEAS easInterface;
    DeVouchAttester devouchAttester;
    bytes32 schemaUID;

    address owner;
    address user = address(2);

    event Attested(bytes32 indexed uid, bytes32 indexed schema, address indexed recipient);

    function setUp() public {
        owner = address(this);

        schemaRegistry = new SchemaRegistry();
        easContract = new EAS(ISchemaRegistry(address(schemaRegistry)));

        devouchAttester = new DeVouchAttester(address(easContract));
        
        schemaUID = schemaRegistry.register(schema, ISchemaResolver(address(0)), true);
        
        devouchAttester.updateSchema(schemaUID);

        vm.label(address(easContract), "EAS");
        vm.label(address(schemaRegistry), "SchemaRegistry");
        vm.label(address(devouchAttester), "DeVouchAttester");
    }

    function testMultiAttest() public {
        address recipient = address(0);
        bytes32[] memory refUIDArray = new bytes32[](2);
        refUIDArray[0] = EMPTY_UID;
        refUIDArray[1] = EMPTY_UID;
        bytes memory data = abi.encode("giveth", "55", true, "this is awesome");

        uint256 initialBalance = address(devouchAttester).balance;
        uint256 fee = devouchAttester.fee();

        vm.deal(user, 1 ether);
        vm.prank(user);

        console.log("Before attestation");

        vm.recordLogs();

        devouchAttester.attest{value: fee}(recipient, refUIDArray, data);

        Vm.Log[] memory entries = vm.getRecordedLogs();

        console.log("After attestation");
        console.log("Number of emitted events:", entries.length);

        for (uint i = 0; i < entries.length; i++) {
            console.log("Event", i);
            console.logBytes32(entries[i].topics[0]); // Event signature
            if (entries[i].topics.length > 1) console.logBytes32(entries[i].topics[1]); // First indexed parameter
            if (entries[i].topics.length > 2) console.logBytes32(entries[i].topics[2]); // Second indexed parameter
            if (entries[i].topics.length > 3) console.logAddress(address(uint160(uint256(entries[i].topics[3])))); // Third indexed parameter (if it's an address)
            console.logBytes(entries[i].data); // Non-indexed parameters
        }

        assertEq(address(devouchAttester).balance, initialBalance + fee);
        assertEq(devouchAttester.schema(), schemaUID);
        assertEq(address(devouchAttester.eas()), address(easContract));
    }
}