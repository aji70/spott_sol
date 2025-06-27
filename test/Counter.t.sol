// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Spott} from "../src/Spott.sol";

contract CounterTest is Test {
    Spott public spott;
    address private moderator = address(0xa);
    address private vendor = address(0xb);

    function setUp() public {
        spott = new Spott(moderator);
    }

    function test_Register_vendor() public {
        vm.startPrank(vendor);
        register_vendor();
        Spott.Vendor memory ven = spott.getVendor(vendor);
        assertEq(ven.id, 1);
        assertEq(ven.owner, vendor);
        assertEq(ven.name, "Vendor1");
        assertEq(ven.location, "Location1");
        assertEq(ven.category, "Category1");
        assertEq(ven.metadataUri, "metadataUri1");
        assertEq(ven.bio, "Bio1");
        assertEq(ven.profileImage, "profileImage1");
        assertTrue(!ven.verified);
        assertTrue(ven.exists);
        vm.stopPrank();
    }

    function test_verify_vendor() public {
        vm.startPrank(vendor);
        register_vendor();
        vm.startPrank(moderator);
        spott.verifyVendor(vendor);
        Spott.Vendor memory ven = spott.getVendor(vendor);
        assertEq(ven.id, 1);
        assertTrue(ven.verified);
        vm.stopPrank();
    }

    function register_vendor() public {
        spott.registerVendor("Vendor1", "Location1", "Category1", "metadataUri1", "Bio1", "profileImage1");
    }
}
