// SPDX-License Identifier: MIT
pragma solidity ^0.8.19;

import {SchemaResolver} from "eas-contracts/contracts/resolver/SchemaResolver.sol";
import {IEAS, Attestation} from "eas-contracts/contracts/IEAS.sol";
import "@openzeppelin-contracts-upgradeable/access/OwnableUpgradeable.sol";

contract DeVouchResolver is SchemaResolver, OwnableUpgradeable {
    uint256 public _targetValue;
    event Attest(address attester);
    event Revoke(address attester);

    constructor(IEAS eas, uint256 targetValue) SchemaResolver(eas) {
        _targetValue = targetValue;
    }

    function isPayable() public pure override returns (bool) {
        return true;
    }

    function onAttest(Attestation calldata attestation, uint256 /*value*/ ) internal view override returns (bool) {
        emit Attest(attestation.attester);
        return value == _targetValue;
    }

    /// @dev Attestation is revokable
    function onRevoke(Attestation calldata, /*attestation*/ uint256 /*value*/ ) internal pure override returns (bool) {
        emit Revoke(attestation.attester);
        return true;
    }

    function setFee(uint256 targetValue) public onlyOwner {
        _targetValue = targetValue;
    }

   
}
