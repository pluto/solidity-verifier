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
        address signer = 0xfdf07A5dCfa7b74f4c28DAb23eaD8B1c43Be801F;
        bytes32 digest = bytes32(0x0ad25b24a05589ed9f2332ac85f5690c8400019f32858c2f6bf24877362d41db);
        bytes32 r = bytes32(0x86c6ab86ac26bfdfd245ab65a05e90cd18afe9f810acb42532adf7570cd0ed77);
        bytes32 s = bytes32(0x17370b1c7a7d7d96155e6144a9bfc9265f81c354b1cb4af7cebe52e601dabfef);
        uint8 v = 27;

        // TODO(WJ 2025-02-17): get manifest and value from the digest

        // assertEq(signatureChecker.verifyNotarySignature(digest, v, r, s, signer, manifest, value), true);
    }
}
