// SPDX-License Identifier: MIT
pragma solidity ^0.8.19;

import {SchemaResolver} from "eas-contracts/contracts/resolver/SchemaResolver.sol";
import {IEAS, Attestation} from "eas-contracts/contracts/IEAS.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract AttesterResolver is SchemaResolver, Ownable {
    address private _targetAttester;

    constructor(IEAS eas, address targetAttester) SchemaResolver(eas) Ownable() {
        _targetAttester = targetAttester;
    }
    /// @dev Returns true if the attestation is from the target attester, only the target attester can make attestations

    function onAttest(Attestation calldata attestation, uint256 /*value*/ ) internal view override returns (bool) {
        return attestation.attester == _targetAttester;
    }

    /// @dev Attestation is revokable
    function onRevoke(Attestation calldata, /*attestation*/ uint256 /*value*/ ) internal pure override returns (bool) {
        return true;
    }

    /// @dev Sets the target attester
    /// @param targetAttester The address of the target attester
    function setTargetAttester(address targetAttester) public onlyOwner {
        _targetAttester = targetAttester;
    }
}
