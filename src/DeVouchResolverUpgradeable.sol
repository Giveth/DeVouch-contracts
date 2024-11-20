// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Initializable} from "@openzeppelin-contracts-upgradeable/proxy/utils/Initializable.sol";
import {OwnableUpgradeable} from "@openzeppelin-contracts-upgradeable/access/OwnableUpgradeable.sol";
import {SchemaResolverUpgradeable} from "./SchemaResolverUpgradeable.sol";
import {IEAS, Attestation} from "eas-contracts/contracts/IEAS.sol";

/// @custom:oz-upgrades-from DeVouchResolverUpgradeable
contract DeVouchResolverUpgradeable is Initializable, SchemaResolverUpgradeable, OwnableUpgradeable {
    uint256 public fee;

    function initialize(IEAS eas, uint256 _fee) public initializer {
        __Ownable_init(_msgSender());
        __SchemaResolver_init(eas); // Initialize the base contract
        fee = _fee;
    }

    function isPayable() public pure override returns (bool) {
        return true;
    }

    function onAttest(Attestation calldata attestation, uint256 value) internal override returns (bool) {
        return value == fee;
    }

    function onRevoke(Attestation calldata attestation, uint256 value) internal override returns (bool) {
        return true;
    }

    function setFee(uint256 newFee) public onlyOwner {
        fee = newFee;
    }

    function withdraw() public onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }
}
