

// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import { IEAS, AttestationRequest, AttestationRequestData, RevocationRequest, RevocationRequestData } from "@ethereum-attestation-service/eas-contracts/contracts/IEAS.sol";
import { NO_EXPIRATION_TIME, EMPTY_UID } from "@ethereum-attestation-service/eas-contracts/contracts/Common.sol";

contract DevouchAttester
{
    event Log(string func, uint256 gas);
    address public owner;
    uint256 public fee = 0.00003 ether;
    address multisig = 0x7D52A0Ab02A6A49a1B4b7c4e79C80F977971f700;
    bytes32 schema = 0x421da38e6ff5eb5d0402a4e9be70e70f961bce228e8a20d1eca19634556247fd;

   /**
     * @dev Set contract deployer as owner
     */
    constructor() {
        owner = msg.sender; // 'msg.sender' is sender of current call, contract deployer for a constructor
    }

    modifier ownerOnly() {
      require(msg.sender == owner, "Only owner can access this function");
      _;
    }

    function updateOwner(address newOwner) public ownerOnly {
        owner = newOwner;
        emit Log("updateOwner", gasleft());
    }

    function updateFee(uint256 newFee) public ownerOnly {
        fee = newFee;
        emit Log("updateFee", gasleft());
    }

    function updateSchema(bytes32 newSchema) public ownerOnly{
        schema = newSchema;
        emit Log("updateSchema", gasleft());
    }

    function attest(address recipient, bytes32 refUID, bytes calldata data) public payable
    {
        require(address(msg.sender).balance >= fee, "Insufficient balance to pay fee");
        require(msg.value == fee, "Must pay the fee amount");

        IEAS(0xC2679fBD37d54388Ce493F1DB75320D236e1815e).attest(
                AttestationRequest({
                    schema: schema,
                    data: AttestationRequestData({
                        recipient: recipient,
                        expirationTime: NO_EXPIRATION_TIME,
                        revocable: true,
                        refUID: refUID,
                        data: data,
                        value:0
                    })
                })
            );
        
        emit Log("attested", gasleft());
    }

    receive() external payable {}

    fallback() external payable {
        emit Log("fallback", gasleft());
    }

    // Function to withdraw Ether from the contract (for testing purposes)
    function withdraw() public {
        // Transfer the Ether to the multisig address
        (bool success, ) = multisig.call{value: address(this).balance}("");
        require(success, "Failed to send Ether");
        emit Log("withdraw", gasleft());
    }
}
