// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

/// @title SignatureChecker
/// @notice A contract that verifies signatures
contract SignatureChecker is Ownable {
    /// @notice Mapping of notary addresses to their validity
    mapping(address => bool) public isNotary;

    uint256 public constant BN254_MODULUS = 21888242871839275222246405745257275088548364400416034343698204186575808495617;

    /// @notice Error for invalid signatures
    error InvalidSignature();
    /// @notice Error for invalid notary addresses
    error InvalidNotary();

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

    /// @notice Verifies a signature
    /// @param _hash The hash of the data that was signed
    /// @param v The recovery id
    /// @param r The R value of the signature
    /// @param s The S value of the signature
    /// @param signer The address that signed the data
    function verifyNotarySignature(bytes32 _hash, uint8 v, bytes32 r, bytes32 s, address signer)
        external
        view
        returns (bool)
    {
        // check if the signer is a notary
        if (!isNotary[signer]) {
            revert InvalidNotary();
        }

        // r is the x-coordinate of the curve point
        // s is the y-coordinate of the curve point
        // v is 27 or 28 based on the y-value being even or odd
        // verify the signature
        address recoveredSigner = ecrecover(_hash, v, r, s);
        if (recoveredSigner != signer) {
            revert InvalidSignature();
        }
        return true;
    }
}
