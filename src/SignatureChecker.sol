// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ECDSA} from "./ECDSA.sol";

// todo: Do we need to have some stateful capabilities?
contract SignatureChecker {
    // todo Replace with our notary address
    address public constant NOTARY_ADDRESS = address(0x34567890abcdef1234567890abcdef1234);

    function isValidSignatureNow(bytes32 hash, bytes memory signature) external pure returns (bool) {
        (address recovered, ECDSA.RecoverError err,) = ECDSA.tryRecover(hash, signature);
        return err == ECDSA.RecoverError.NoError && recovered == NOTARY_ADDRESS;
    }
}
