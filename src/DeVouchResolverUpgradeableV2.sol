// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Initializable} from "@openzeppelin-contracts-upgradeable/proxy/utils/Initializable.sol";
import {OwnableUpgradeable} from "@openzeppelin-contracts-upgradeable/access/OwnableUpgradeable.sol";
import {SchemaResolverUpgradeable} from "./SchemaResolverUpgradeable.sol";
import {IEAS, Attestation} from "eas-contracts/contracts/IEAS.sol";

/// @custom:oz-upgrades-from DeVouchResolverUpgradeable
contract DeVouchResolverUpgradeableV2 is Initializable, SchemaResolverUpgradeable, OwnableUpgradeable {
    uint256 private _targetValue;

    function initialize(IEAS eas, uint256 targetValue) public initializer {
        __Ownable_init(_msgSender());
        __SchemaResolver_init(eas); // Initialize the base contract
        _targetValue = targetValue;
    }

    function isPayable() public pure override returns (bool) {
        return true;
    }

    function onAttest(Attestation calldata attestation, uint256 value) internal override returns (bool) {
        return true;
    }

    function onRevoke(Attestation calldata attestation, uint256 value) internal override returns (bool) {
        return true;
    }

    function setFee(uint256 targetValue) public onlyOwner {
        _targetValue = targetValue;
    }

    function withdraw() public onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }
}
