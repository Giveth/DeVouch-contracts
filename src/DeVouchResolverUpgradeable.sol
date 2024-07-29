// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Initializable} from "@openzeppelin-contracts-upgradeable/proxy/utils/Initializable.sol";
import {OwnableUpgradeable} from "@openzeppelin-contracts-upgradeable/access/OwnableUpgradeable.sol";
import {SchemaResolverUpgradeable} from "./SchemaResolverUpgradeable.sol";
import {IEAS, Attestation} from "eas-contracts/contracts/IEAS.sol";

contract DeVouchResolverUpgradeable is Initializable, SchemaResolverUpgradeable, OwnableUpgradeable {
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
        require(value == _targetValue, "DeVouchResolver: Value does not match target value");
        return value == _targetValue;
    }

    function onRevoke(Attestation calldata attestation, uint256 /*value*/ ) internal override returns (bool) {
        return true;
    }

    function setFee(uint256 targetValue) public onlyOwner {
        _targetValue = targetValue;
    }
}
