// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

/// @title SignatureChecker
/// @notice A contract that verifies signatures
contract SignatureChecker is Ownable {
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
