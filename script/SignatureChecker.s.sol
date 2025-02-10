// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {SignatureChecker} from "../src/SignatureChecker.sol";

contract SignatureCheckerScript is Script {
    SignatureChecker public signatureChecker;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        signatureChecker = new SignatureChecker();

        vm.stopBroadcast();
    }
}
