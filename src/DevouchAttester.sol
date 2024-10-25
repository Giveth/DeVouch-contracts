// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {
    IEAS,
    AttestationRequestData,
    MultiAttestationRequest
} from "eas-contracts/contracts/IEAS.sol";
import { NO_EXPIRATION_TIME } from "eas-contracts/contracts/Common.sol";

contract DeVouchAttester {
    address public owner;
    uint256 public fee = 0.00003 ether;
    address public multisig;
    bytes32 public schema = 0x421da38e6ff5eb5d0402a4e9be70e70f961bce228e8a20d1eca19634556247fd;

    IEAS public eas;
    bool public paused;

    error Unauthorized();
    error InvalidFee();
    error InvalidSchema();
    error ContractPaused();
    error WithdrawFailed();
    error InvalidMultisig(); 

    /**
    * @dev Set contract deployer as owner and initial multisig
    */
    constructor(address _easAddress) {
        owner = msg.sender;
        multisig = 0x7D52A0Ab02A6A49a1B4b7c4e79C80F977971f700;
        eas = IEAS(_easAddress);
    }

    modifier ownerOnly() {
        if (msg.sender != owner) revert Unauthorized();
        _;
    }

    modifier whenNotPaused() {
        if (paused) revert ContractPaused();
        _;
    }

    function updateOwner(address newOwner) public ownerOnly {
        owner = newOwner;
    }

    function updateMultisig(address newMultisig) public ownerOnly {
        if (newMultisig == address(0)) revert InvalidMultisig();
        multisig = newMultisig;
    }

    function updateFee(uint256 newFee) public ownerOnly {
        fee = newFee;
    }

    function updateSchema(bytes32 newSchema) public ownerOnly {
        if (newSchema == 0) revert InvalidSchema();
        schema = newSchema;
    }

    function updateEAS(address newEASAddress) public ownerOnly {
        eas = IEAS(newEASAddress);
    }

    function togglePause() public ownerOnly {
        paused = !paused;
    }

    function attest(
        address recipient,
        bytes32[] calldata refUIDArray,
        bytes calldata data
    ) public payable whenNotPaused {
        if (msg.value != fee) revert InvalidFee();

        uint256 len = refUIDArray.length;
        AttestationRequestData[] memory requestDataArray = new AttestationRequestData[](len);

        for (uint256 i = 0; i < len; ++i) {
            requestDataArray[i] = AttestationRequestData({
                recipient: recipient,
                expirationTime: NO_EXPIRATION_TIME,
                revocable: true,
                refUID: refUIDArray[i],
                data: data,
                value: 0
            });
        }

        MultiAttestationRequest[] memory multiRequests = new MultiAttestationRequest[](1);
        multiRequests[0] = MultiAttestationRequest({
            schema: schema,
            data: requestDataArray
        });

        eas.multiAttest(multiRequests);
    }

    receive() external payable {}

    fallback() external payable {}

    function withdraw() public {
        uint256 amount = address(this).balance;
        (bool success, ) = multisig.call{value: amount}("");
        if (!success) revert WithdrawFailed();
    }
}