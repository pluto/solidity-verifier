// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {SignatureChecker} from "../src/SignatureChecker.sol";

contract SignatureCheckerTest is Test {
    SignatureChecker public signatureChecker;

    function setUp() public {
        signatureChecker = new SignatureChecker(0xfdf07A5dCfa7b74f4c28DAb23eaD8B1c43Be801F);
    }

    function test_isValidSignatureNow() public view {
        
        // TEST vector from NOTARY
        // "merkle_root": "0x2943593524b7c19d5448e2489772f3de80d71418c3a62b25ef39559334acbffe", 
        // "signature" is comprised of 160 characters
        // 0x3045022100 : Not sure what the firstones here are
        // 9039bd2ded8fd5e09b62a04a3d25d2d13f0f45f40c1b4ca6c3aece4a71f92c14 : This is the R value
        // 0220 : Not sure what the secondones here are
        // 16d62561a8939ed49c97d9621c47988cf74b5b5074f89f2b2c6b9b18a6eeb1b2 : This is the S value
        // "signature_r": "0x9039bd2ded8fd5e09b62a04a3d25d2d13f0f45f40c1b4ca6c3aece4a71f92c14", 
        // "signature_s": "0x16d62561a8939ed49c97d9621c47988cf74b5b5074f89f2b2c6b9b18a6eeb1b2", 
        // "signature_v": 28, 
        // "signer": "0xfdf07a5dcfa7b74f4c28dab23ead8b1c43be801f"
        address signer = 0xfdf07A5dCfa7b74f4c28DAb23eaD8B1c43Be801F;
        // There are interestingly 129 characters in this signature, the ercrecover opcode expects 65 where 32 are R, 32 are S, and 1 is V
        bytes32 _hash = bytes32(0x2943593524b7c19d5448e2489772f3de80d71418c3a62b25ef39559334acbffe);
        uint8 v = 28;
        bytes32 r = bytes32(0x9039bd2ded8fd5e09b62a04a3d25d2d13f0f45f40c1b4ca6c3aece4a71f92c14);
        bytes32 s = bytes32(0x16d62561a8939ed49c97d9621c47988cf74b5b5074f89f2b2c6b9b18a6eeb1b2);
        // verify signature
        assertEq(signatureChecker.verifySignature(_hash, v, r, s, signer), true);
    }
}
