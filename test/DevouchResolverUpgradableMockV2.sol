// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {DeVouchResolverUpgradeable} from "../src/DeVouchResolverUpgradeable.sol";

/// @custom:oz-upgrades-from DeVouchResolverUpgradeable
contract DevouchResolverUpgradableMockV2 is DeVouchResolverUpgradeable {
    function foo() public pure returns (string memory) {
        return "foo";
    }
}
