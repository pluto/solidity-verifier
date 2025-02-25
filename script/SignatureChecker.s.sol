// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {Verifier} from "../src/Verifier.sol";

contract VerifierScript is Script {
    Verifier public verifier;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        verifier = new Verifier(0xfdf07A5dCfa7b74f4c28DAb23eaD8B1c43Be801F);

        vm.stopBroadcast();
    }
}
