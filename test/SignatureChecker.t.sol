// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {SignatureChecker} from "../src/SignatureChecker.sol";

contract SignatureCheckerTest is Test {
    SignatureChecker public signatureChecker;

    function setUp() public {
        signatureChecker = new SignatureChecker(0xfdf07A5dCfa7b74f4c28DAb23eaD8B1c43Be801F);
    }

    function test_isValidSignatureNow() public {
        // TEST vector from web-prover @ githash 2dc768e818d6f9fef575a88a2ceb80c0ed11974f
        address signer = 0xfdf07A5dCfa7b74f4c28DAb23eaD8B1c43Be801F;
        bytes32 digest = bytes32(0xe45537be7b5cd288c9c46b7e027b4f5a66202146012f792c1b1cabb65828994b);
        bytes32 r = bytes32(0x36e820b3524e9ffffe0b4ee49e4131cc362fd161821c1dfc8757dc6186f31c96);
        bytes32 s = bytes32(0x416e537065673e3028eca37cf3cbe805a3d2fafbc47235fee5e89df5f0509a9c);
        uint8 v = 27;

        bytes32 value = 0x8452c9b9140222b08593a26daa782707297be9f7b3e8281d7b4974769f19afd0;
        bytes32 manifest = 0x7df909980a1642d0370a4a510422201ce525da6b319a7b9e9656771fa7336d5a;

        assertEq(signatureChecker.verifyNotarySignature(digest, v, r, s, signer, manifest, value), true);
    }
}
