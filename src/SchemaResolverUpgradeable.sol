// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin-contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin-contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin-contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {IEAS, Attestation} from "eas-contracts/contracts/IEAS.sol";
import { AccessDenied, InvalidEAS, InvalidLength, uncheckedInc } from "eas-contracts/contracts/Common.sol";
import { Semver } from "eas-contracts/contracts/Semver.sol";
import { ISchemaResolver } from "eas-contracts/contracts/resolver/ISchemaResolver.sol";

/// @title SchemaResolver
/// @notice The base schema resolver contract.
abstract contract SchemaResolver is ISchemaResolver, Semver, Initializable, OwnableUpgradeable, UUPSUpgradeable {
    error InsufficientValue();
    error NotPayable();

    // The global EAS contract.
    IEAS internal _eas;

    /// @dev Initializes the contract with the given version numbers.
    /// @param eas The address of the global EAS contract.
    function __SchemaResolver_init(IEAS eas) internal initializer {
        __Ownable_init();
        __UUPSUpgradeable_init();
        if (address(eas) == address(0)) {
            revert InvalidEAS();
        }

        _eas = eas;
    }

    /// @dev Ensures that only the EAS contract can make this call.
    modifier onlyEAS() {
        _onlyEAS();

        _;
    }

    /// @inheritdoc ISchemaResolver
    function isPayable() public pure virtual returns (bool) {
        return false;
    }

    /// @dev ETH callback.
    receive() external payable virtual {
        if (!isPayable()) {
            revert NotPayable();
        }
    }

    /// @inheritdoc ISchemaResolver
    function attest(Attestation calldata attestation) external payable onlyEAS returns (bool) {
        return onAttest(attestation, msg.value);
    }

    /// @inheritdoc ISchemaResolver
    function multiAttest(
        Attestation[] calldata attestations,
        uint256[] calldata values
    ) external payable onlyEAS returns (bool) {
        uint256 length = attestations.length;
        if (length != values.length) {
            revert InvalidLength();
        }

        uint256 remainingValue = msg.value;

        for (uint256 i = 0; i < length; i = uncheckedInc(i)) {
            uint256 value = values[i];
            if (value > remainingValue) {
                revert InsufficientValue();
            }

            if (!onAttest(attestations[i], value)) {
                return false;
            }

            unchecked {
                remainingValue -= value;
            }
        }

        return true;
    }

    /// @inheritdoc ISchemaResolver
    function revoke(Attestation calldata attestation) external payable onlyEAS returns (bool) {
        return onRevoke(attestation, msg.value);
    }

    /// @inheritdoc ISchemaResolver
    function multiRevoke(
        Attestation[] calldata attestations,
        uint256[] calldata values
    ) external payable onlyEAS returns (bool) {
        uint256 length = attestations.length;
        if (length != values.length) {
            revert InvalidLength();
        }

        uint256 remainingValue = msg.value;

        for (uint256 i = 0; i < length; i = uncheckedInc(i)) {
            uint256 value = values[i];
            if (value > remainingValue) {
                revert InsufficientValue();
            }

            if (!onRevoke(attestations[i], value)) {
                return false;
            }

            unchecked {
                remainingValue -= value;
            }
        }

        return true;
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    function onAttest(Attestation calldata attestation, uint256 value) internal virtual returns (bool);

    function onRevoke(Attestation calldata attestation, uint256 value) internal virtual returns (bool);

    function _onlyEAS() private view {
        if (msg.sender != address(_eas)) {
            revert AccessDenied();
        }
    }
}

