// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin-contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin-contracts-upgradeable/access/OwnableUpgradeable.sol";
import {SchemaResolverUpgradable} from "./SchemaResolverUpgradeable.sol";
import {IEAS, Attestation} from "eas-contracts/contracts/IEAS.sol";

contract DeVouchResolver is Initializable, SchemaResolverUpgradable {
    uint256 private _targetValue;

    event Attest(address attester);
    event Revoke(address attester);

    function initialize(IEAS eas, uint256 targetValue) public initializer {
        __SchemaResolver_init(eas); // Initialize the base contract
        _targetValue = targetValue;
    }

    function isPayable() public pure override returns (bool) {
        return true;
    }

    function onAttest(Attestation calldata attestation, uint256 value) internal override returns (bool) {
        emit Attest(attestation.attester);
        return value == _targetValue;
    }

    function onRevoke(Attestation calldata attestation, uint256 /*value*/ ) internal override returns (bool) {
        emit Revoke(attestation.attester);
        return true;
    }

    function setFee(uint256 targetValue) public onlyOwner {
        _targetValue = targetValue;
    }
}
