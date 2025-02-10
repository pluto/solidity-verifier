// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import {ECDSA} from "./ECDSA.sol";

// todo: Do we need to have some stateful capabilities?
contract SignatureChecker {
    // todo Replace with our notary address
    // 0xfdf07A5dCfa7b74f4c28DAb23eaD8B1c43Be801F
    address public constant NOTARY_ADDRESS = address(0xfdf07A5dCfa7b74f4c28DAb23eaD8B1c43Be801F);

    function isValidSignatureNow(bytes32 hash, bytes memory signature) external pure returns (bool) {
        (address recovered, ECDSA.RecoverError err,) = ECDSA.tryRecover(hash, signature);
        return err == ECDSA.RecoverError.NoError && recovered == NOTARY_ADDRESS;

        /// this decomposes the signature into r, s, v
        // r is the x-coordinate of the curve point
        // s is the y-coordinate of the curve point

        // v is 0 for an even y-value
        // v is 1 for an odd y-value
    }
}
