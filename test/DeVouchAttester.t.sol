// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

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
    address multisig;

    event Attested(bytes32 indexed uid, bytes32 indexed schema, address indexed recipient);

    function setUp() public {
        owner = address(this);

        schemaRegistry = new SchemaRegistry();
        easContract = new EAS(ISchemaRegistry(address(schemaRegistry)));

        devouchAttester = new DeVouchAttester(address(easContract));
        
        schemaUID = schemaRegistry.register(schema, ISchemaResolver(address(0)), true);
        
        devouchAttester.updateSchema(schemaUID);

        multisig = devouchAttester.multisig();

        vm.label(address(easContract), "EAS");
        vm.label(address(schemaRegistry), "SchemaRegistry");
        vm.label(address(devouchAttester), "DeVouchAttester");
        vm.label(multisig, "Multisig");
    }

    function testMultiAttest() public {
        address recipient = address(0);
        bytes32[] memory refUIDArray = new bytes32[](2);
        refUIDArray[0] = EMPTY_UID;
        refUIDArray[1] = EMPTY_UID;
        bytes memory data = abi.encode("giveth", "55", true, "this is awesome");

        uint256 fee = devouchAttester.fee();
        
        vm.deal(user, 1 ether);

        uint256 userInitialBalance = user.balance;
        uint256 contractInitialBalance = address(devouchAttester).balance;
        uint256 multisigInitialBalance = multisig.balance;

        console.log("\n--------------------");
        console.log("Starting Multi-Attest Test");
        console.log("--------------------");
        console.log("Attestation fee:", fee);
        console.log("User initial balance:", userInitialBalance);
        console.log("Contract initial balance:", contractInitialBalance);
        console.log("Multisig initial balance:", multisigInitialBalance);

        vm.prank(user);
        vm.recordLogs();
        devouchAttester.attest{value: fee}(recipient, refUIDArray, data);

        Vm.Log[] memory entries = vm.getRecordedLogs();

        uint256 userFinalBalance = user.balance;
        uint256 contractFinalBalance = address(devouchAttester).balance;
        uint256 multisigFinalBalance = multisig.balance;

        console.log("\n--------------------");
        console.log("Attestation Complete");
        console.log("--------------------");
        console.log("Number of emitted events:", entries.length);
        console.log("User final balance:", userFinalBalance);
        console.log("Contract final balance:", contractFinalBalance);
        console.log("Multisig final balance:", multisigFinalBalance);

        console.log("\n--------------------");
        console.log("Assertions");
        console.log("--------------------");

        assertEq(entries.length, 2, "Should emit two events for multi-attest");
        console.log(" >> Correct number of events emitted");

        assertEq(userFinalBalance, userInitialBalance - fee, "User balance should decrease by fee amount");
        console.log(" >> User balance decreased correctly");

        if (contractFinalBalance > contractInitialBalance) {
            assertEq(contractFinalBalance, contractInitialBalance + fee, "Contract balance should increase by fee amount");
            console.log(" >> Fee is held in the contract");
        } else if (multisigFinalBalance > multisigInitialBalance) {
            assertEq(multisigFinalBalance, multisigInitialBalance + fee, "Multisig balance should increase by fee amount");
            console.log(" >> Fee was sent to the multisig");
        } else {
            fail();
            console.log(" >> Fee was not properly accounted for");
        }

        assertEq(devouchAttester.schema(), schemaUID, "Schema in DevouchAttester should match the set schema");
        console.log(" >> Schema in DevouchAttester is correct");

        assertEq(address(devouchAttester.eas()), address(easContract), "EAS address in DevouchAttester should be correct");
        console.log(" >> EAS address in DevouchAttester is correct");

        console.log("\n--------------------");
        console.log("Test Complete");
        console.log("--------------------");
    }
}