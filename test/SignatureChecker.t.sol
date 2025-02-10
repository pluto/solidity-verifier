// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {SignatureChecker} from "../src/SignatureChecker.sol";

contract SignatureCheckerTest is Test {
    SignatureChecker public signatureChecker;

    function setUp() public {
        signatureChecker = new SignatureChecker();
    }

    function test_isValidSignatureNow() public view {
        // Replace with our notary proof hash
        bytes32 hash = keccak256("test");

        // Replace with our notary signature
        bytes memory signature =
            abi.encodePacked(bytes32(0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef));

        // verify signature
        assertEq(signatureChecker.isValidSignatureNow(hash, signature), true);
    }
}
