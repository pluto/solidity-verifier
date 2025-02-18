// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

/// @title SignatureChecker
/// @notice A contract that verifies signatures
contract SignatureChecker is Ownable {
    /// @notice Mapping of notary addresses to their validity
    mapping(address => bool) public isNotary;

    /// valid digests for a given address
    mapping(address => bytes32) public digests;

    uint256 public constant BN254_MODULUS =
        21888242871839275222246405745257275088548364400416034343698204186575808495617;

    /// @notice Error for invalid signatures
    error InvalidSignature();
    /// @notice Error for invalid notary addresses
    error InvalidNotary();
    /// @notice Error for invalid digest
    error InvalidDigest();
    /// @notice Error for invalid signature length
    error InvalidSignatureLength();

    /// @notice Constructor configures the notary address
    /// @param _notaryAddress The address of the notary to add
    constructor(address _notaryAddress) Ownable(msg.sender) {
        isNotary[_notaryAddress] = true;
    }

    /// @notice Adds a notary
    /// @param _notaryAddress The address of the notary to add
    function addNotary(address _notaryAddress) external onlyOwner {
        isNotary[_notaryAddress] = true;
    }

    /// @notice Removes a notary
    /// @param _notaryAddress The address of the notary to remove
    function removeNotary(address _notaryAddress) external onlyOwner {
        isNotary[_notaryAddress] = false;
    }

    // Check to see that the digest is a merkle root of a keccak256 hash of a leafs = (keccak(value), keccak(manifest))
    function verify_digest(bytes32 _digest, bytes32 _manifest, bytes32 _value) internal pure returns (bool) {
        bytes32 root = keccak256(abi.encodePacked(_value, _manifest));
        return _digest == root;
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
        digests[msg.sender] = digest;
        return true;
    }
}
