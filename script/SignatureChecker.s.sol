// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {PlutoAttestationVerifier} from "../src/Verifier.sol";

contract VerifierScript is Script {
    PlutoAttestationVerifier public verifier;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        verifier = new PlutoAttestationVerifier(0x209Af77DfDaba352890b0Bc9B86A25bE67eF436A);

        vm.stopBroadcast();
    }
}
