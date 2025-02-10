// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

// todo: Do we need to have some stateful capabilities?
contract SignatureChecker is Ownable {
    // Mapping of notary addresses to their validity
    mapping(address => bool) public isNotary;

    // error for invalid signatures
    error InvalidSignature();
    error InvalidNotary();

    // constructor configures the notary address
    constructor(address _notaryAddress) Ownable(msg.sender) {
        isNotary[_notaryAddress] = true;
    }

    function addNotary(address _notaryAddress) external onlyOwner {
        isNotary[_notaryAddress] = true;
    }

    function removeNotary(address _notaryAddress) external onlyOwner {
        isNotary[_notaryAddress] = false;
    }

    function verifySignature(bytes32 _hash, uint8 v, bytes32 r, bytes32 s, address signer)
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
