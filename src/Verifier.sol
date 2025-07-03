// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

/// @title Verifier
/// @notice A contract that verifies signatures
contract Verifier is Ownable {
    /// @notice Mapping of notary addresses to their validity
    mapping(address => bool) public isNotary;

    /// valid digests for a given address
    mapping(bytes32 => address) public digests;

    /// @notice Error for invalid signatures
    error InvalidSignature();
    /// @notice Error for invalid notary addresses
    error InvalidNotary();
    /// @notice Error for invalid digest
    error InvalidDigest();
    /// @notice Error for invalid signature length
    error InvalidSignatureLength();
    /// @notice Error for duplicate proof, meaning the proofs is already associated with another address
    error DuplicateProof();

    /// @notice Constructor configures the notary address
    /// @param notaryAddress The address of the notary to add
    constructor(address notaryAddress) Ownable(msg.sender) {
        isNotary[notaryAddress] = true;
    }

    /// @notice Adds a notary
    /// @param notaryAddress The address of the notary to add
    function addNotary(address notaryAddress) external onlyOwner {
        isNotary[notaryAddress] = true;
    }

    /// @notice Removes a notary
    /// @param notaryAddress The address of the notary to remove
    function removeNotary(address notaryAddress) external onlyOwner {
        isNotary[notaryAddress] = false;
    }

    // Check to see that the digest is a merkle root of a keccak256 hash of a leafs = (keccak(value), keccak(manifest))
    function verify_digest(bytes32 digest, bytes32 manifest, bytes32 value) internal pure returns (bool) {
        bytes32 root = keccak256(abi.encodePacked(value, manifest));
        return digest == root;
    }

    /// @notice Verifies a signature
    /// @param digest The hash of the data that was signed
    /// @param v The recovery id
    /// @param r The R value of the signature
    /// @param s The S value of the signature
    /// @param signer The address that signed the data
    /// @param manifest The manifest of the data
    /// @param value The value of the data
    function verifyNotarySignature(
        bytes32 digest,
        uint8 v,
        bytes32 r,
        bytes32 s,
        address signer,
        bytes32 manifest,
        bytes32 value
    ) external returns (bool) {
        // check if the signer is a notary
        if (!isNotary[signer]) {
            revert InvalidNotary();
        }
        if (!verify_digest(digest, manifest, value)) {
            revert InvalidDigest();
        }

        // r is the x-coordinate of the curve point
        // s is the y-coordinate of the curve point
        // v is 27 or 28 based on the y-value being even or odd
        // verify the signature
        address recoveredSigner = ecrecover(digest, v, r, s);
        if (recoveredSigner != signer) {
            revert InvalidSignature();
        }

        // TODO(WJ 2025-02-20): Should check for any sender.
        if (digests[digest] == msg.sender) {
            revert DuplicateProof();
        }

        digests[digest] = msg.sender;
        return true;
    }
}

contract PlutoAttestationVerifier {
    struct ProofData {
        string key;
        string value;
    }

    struct AttestationInput {
        string version;
        string scriptRaw;
        string issuedAt;
        string nonce;
        string sessionId;
        ProofData[] data;
    }

    struct AttestationSignature {
        bytes32 digest;
        uint8 v;
        bytes32 r;
        bytes32 s;
        address expectedSigner;
    }

    Verifier public verifier;

    constructor(address notaryAddress) {
        verifier = new Verifier(notaryAddress);
    }

    /**
     * @dev Calculate script hash from version and script content
     */
    function calculateScriptHash(string memory version, string memory scriptRaw) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(version, scriptRaw));
    }

    /**
     * @dev Calculate session hash from all session components
     */
    function calculateSessionHash(
        string memory version,
        string memory issuedAt,
        string memory nonce,
        string memory sessionId,
        ProofData[] memory data
    ) public pure returns (bytes32) {
        // Build the hash incrementally
        bytes memory hashData = abi.encodePacked(version, issuedAt, nonce, sessionId);

        for (uint256 i = 0; i < data.length; i++) {
            hashData = abi.encodePacked(hashData, data[i].key, data[i].value);
        }

        return keccak256(hashData);
    }

    /**
     * @dev Calculate digest from session and script hashes
     */
    function calculateDigest(bytes32 sessionHash, bytes32 scriptHash) public pure returns (bytes32) {
        // reportData = sessionHash + scriptHash (64 bytes)
        bytes memory reportData = abi.encodePacked(sessionHash, scriptHash);
        return keccak256(reportData);
    }

    /**
     * @dev Verify complete attestation by calculating hashes and checking signature
     */
    function verifyAttestation(AttestationInput memory input, AttestationSignature memory signature)
        public
        returns (bool)
    {
        // Calculate script hash
        bytes32 scriptHash = calculateScriptHash(input.version, input.scriptRaw);

        // Calculate session hash
        bytes32 sessionHash =
            calculateSessionHash(input.version, input.issuedAt, input.nonce, input.sessionId, input.data);

        // Calculate digest
        bytes32 digest = calculateDigest(sessionHash, scriptHash);

        // Verify the digest matches
        if (digest != signature.digest) {
            return false;
        }

        // Call the signature verification contract
        bool success = verifier.verifyNotarySignature(
            signature.digest, signature.v, signature.r, signature.s, signature.expectedSigner, scriptHash, sessionHash
        );

        if (!success) {
            return false;
        }

        return success;
    }

    /**
     * @dev Batch verify multiple attestations
     */
    function verifyMultipleAttestations(AttestationInput[] memory inputs, AttestationSignature[] memory signatures)
        public
        returns (bool[] memory)
    {
        require(inputs.length == signatures.length, "Array length mismatch");

        bool[] memory results = new bool[](inputs.length);

        for (uint256 i = 0; i < inputs.length; i++) {
            results[i] = verifyAttestation(inputs[i], signatures[i]);
        }

        return results;
    }

    /**
     * @dev Get calculated hashes for debugging
     */
    function getCalculatedHashes(AttestationInput memory input)
        public
        pure
        returns (bytes32 scriptHash, bytes32 sessionHash, bytes32 digest)
    {
        scriptHash = calculateScriptHash(input.version, input.scriptRaw);
        sessionHash = calculateSessionHash(input.version, input.issuedAt, input.nonce, input.sessionId, input.data);
        digest = calculateDigest(sessionHash, scriptHash);
    }

    /**
     * @dev Helper function to create ProofData array from parallel arrays
     */
    function createProofDataArray(string[] memory keys, string[] memory values)
        public
        pure
        returns (ProofData[] memory)
    {
        require(keys.length == values.length, "Array length mismatch");

        ProofData[] memory proofData = new ProofData[](keys.length);
        for (uint256 i = 0; i < keys.length; i++) {
            proofData[i] = ProofData(keys[i], values[i]);
        }

        return proofData;
    }
}
