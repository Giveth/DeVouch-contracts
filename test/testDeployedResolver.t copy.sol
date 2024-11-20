// SPDX License Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/Script.sol";
import {EAS, NO_EXPIRATION_TIME, EMPTY_UID} from "eas-contracts/contracts/EAS.sol";
import {
    IEAS, AttestationRequestData, AttestationRequest, MultiAttestationRequest
} from "eas-contracts/contracts/IEAS.sol";
import {DeVouchResolverUpgradeable} from "src/DeVouchResolverUpgradeable.sol";
import {Upgrades, Options} from "openzeppelin-foundry-upgrades/Upgrades.sol";

contract TestAttest is Test {
    IEAS easContract = IEAS(0xC2679fBD37d54388Ce493F1DB75320D236e1815e);

    DeVouchResolverUpgradeable devouchResolver =
        DeVouchResolverUpgradeable(payable(address(0x2AC383909Ff12F8a119220eEc16Dd081BB22f48E)));
    bytes32 schemaUID = 0xe1d4909e8cd9135683c6408291e90bce5771291a3fbcbb797ee6834359b3d4f3;
    uint256 fee = 0.0001 ether;
    // string schema = "string someData";

    address owner = address(4);

    event Attest(address attester);
    event Revoke(address attester);

    function setUp() public virtual {
        uint256 sepoliaFork = vm.createFork("https://sepolia.drpc.org");
        vm.selectFork(sepoliaFork);

        vm.label(address(easContract), "EAS");
        vm.label(address(devouchResolver), "DeVouchResolver");
    }

    function testAttest() public {
        uint256 easBalanceBefore = address(easContract).balance;
        uint256 devouchBalanceBefore = address(devouchResolver).balance;
        vm.expectEmit(true, true, false, false);
        emit IEAS.Attested(address(0), address(this), 0, schemaUID);
        bytes32 uid = easContract.attest{value: fee}(
            AttestationRequest({
                schema: schemaUID,
                data: AttestationRequestData({
                    recipient: address(0),
                    expirationTime: NO_EXPIRATION_TIME,
                    revocable: true,
                    refUID: EMPTY_UID,
                    data: abi.encode("so good"),
                    //  "string projectSource, string projectId, bool vouch, string comment";
                    value: fee
                })
            })
        );

        assertNotEq(uid, bytes32(0));

        uint256 easBalanceAfter = address(easContract).balance;
        uint256 devouchBalanceAfter = address(devouchResolver).balance;

        console.log("EAS Balance Before: %s", easBalanceBefore);
        console.log("EAS Balance After: %s", easBalanceAfter);

        console.log("DeVouch Balance Before: %s", devouchBalanceBefore);
        console.log("DeVouch Balance After: %s", devouchBalanceAfter);
    }

    function testMultiAttest() public {
        uint256 easBalanceBefore = address(easContract).balance;
        uint256 devouchBalanceBefore = address(devouchResolver).balance;

        MultiAttestationRequest[] memory requests = new MultiAttestationRequest[](1);
        requests[0].schema = schemaUID;

        AttestationRequestData[] memory data = new AttestationRequestData[](2);
        data[0] = AttestationRequestData({
            recipient: address(0),
            expirationTime: NO_EXPIRATION_TIME,
            revocable: true,
            refUID: EMPTY_UID,
            data: abi.encode("so good"),
            value: fee
        });
        data[1] = AttestationRequestData({
            recipient: address(0),
            expirationTime: NO_EXPIRATION_TIME,
            revocable: true,
            refUID: EMPTY_UID,
            data: abi.encode("so much better"),
            value: fee
        });

        requests[0].data = data;

        bytes32[] memory uids = easContract.multiAttest{value: fee * 2}(requests);

        assertNotEq(uids[0], bytes32(0));
        assertNotEq(uids[1], bytes32(0));

        uint256 easBalanceAfter = address(easContract).balance;
        uint256 devouchBalanceAfter = address(devouchResolver).balance;

        console.log("EAS Balance Before: %s", easBalanceBefore);
        console.log("EAS Balance After: %s", easBalanceAfter);

        console.log("DeVouch Balance Before: %s", devouchBalanceBefore);
        console.log("DeVouch Balance After: %s", devouchBalanceAfter);
    }
}
