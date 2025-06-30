// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Verifier, PlutoAttestationVerifier} from "../src/Verifier.sol";

contract VerifierTest is Test {
    Verifier public verifier;

    function setUp() public {
        verifier = new Verifier(0xF2E3878C9aB6A377D331E252F6bF3673d8e87323);
    }

    function test_isValidSignature() public {
        // TEST vector from web-prover @ githash 2dc768e818d6f9fef575a88a2ceb80c0ed11974f
        address signer = 0xF2E3878C9aB6A377D331E252F6bF3673d8e87323;
        bytes32 digest = bytes32(0x3858f7da505d328a26770f8cac2170c0e937261dc451e34707dd8b2600b3a63e);
        bytes32 r = bytes32(0xcd21eef84a7686c71e6c3cc801b4cc6883d3e9e4ba0da78ab1245897f6bcbe43);
        bytes32 s = bytes32(0x6985c20ecd47b70c007f95412c0231b20d16a56001d7d214e427acf6b5615e22);
        uint8 v = 27;

        bytes32 value = 0x0e38baef3358f6094095731571734ed4e83492afd88025e0e929d3de25286a60;
        bytes32 manifest = 0xdd2a3dcaa72abdb5de17624afbf7f4216fa72a4998c82383617818ce80bb03b6;

        assertEq(verifier.verifyNotarySignature(digest, v, r, s, signer, manifest, value), true);
    }
}

// Example usage contract showing how to use the verifier
contract PlutoAttestationExample is Test {
    PlutoAttestationVerifier public verifier;

    function setUp() public {
        verifier = new PlutoAttestationVerifier(0xF2E3878C9aB6A377D331E252F6bF3673d8e87323);
    }

    /**
     * @dev Example function demonstrating attestation verification
     */
    function test_verifyExampleAttestation() public {
        // Create the proof data array
        string[] memory keys = new string[](2);
        string[] memory values = new string[](2);
        keys[0] = "a";
        keys[1] = "c";
        values[0] = "10";
        values[1] = "\"d\"";

        PlutoAttestationVerifier.ProofData[] memory proofData = verifier.createProofDataArray(keys, values);

        // Create the attestation input
        PlutoAttestationVerifier.AttestationInput memory input = PlutoAttestationVerifier.AttestationInput({
            version: "v1",
            scriptRaw: "import { createSession } from '@plutoxyz/automation';\nconst session = await createSession();\nawait session.prove('bank_balance', { a: 10, c: 'd' });",
            issuedAt: "2025-06-30T10:45:20Z",
            nonce: "0x7b830a98e58e284b",
            sessionId: "f4c38687-6fe0-40b8-8c05-e4a085856b05",
            data: proofData
        });

        // Create the signature struct
        PlutoAttestationVerifier.AttestationSignature memory signature = PlutoAttestationVerifier.AttestationSignature({
            digest: 0x088965a798b565d02f3ae18aa703609c645668d438969198166e4d9215a77f30,
            v: 27,
            r: 0x44a1b7809a7903ea087e7b5ce4092c24020134c5c3ea008656853f6d6da51b54,
            s: 0x1e8b4bcbb716639b038d613257eac91d8edfaa1a5daa924307ce6cf4490b1edb,
            expectedSigner: 0xF2E3878C9aB6A377D331E252F6bF3673d8e87323
        });

        bool success = verifier.verifyAttestation(input, signature);
        assertEq(success, true);
    }
}
