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
        // 9039BD2DED8FD5E09B62A04A3D25D2D13F0F45F40C1B4CA6C3AECE4A71F92C1416D62561A8939ED49C97D9621C47988CF74B5B5074F89F2B2C6B9B18A6EEB1B2
        // 9039BD2DED8FD5E09B62A04A3D25D2D13F0F45F40C1B4CA6C3AECE4A71F92C1416D62561A8939ED49C97D9621C47988CF74B5B5074F89F2B2C6B9B18A6EEB1B2
        // There are interestingly 129 characters in this signature, the ercrecover opcode expects 65 where 32 are R, 32 are S, and 1 is V
        bytes memory signature =
            abi.encodePacked(bytes32(0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef));

        // verify signature
        assertEq(signatureChecker.isValidSignatureNow(hash, signature), true);
    }
}
