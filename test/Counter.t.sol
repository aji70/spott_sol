// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Spott} from "../src/Spott.sol";

contract CounterTest is Test {
    Spott public spott;
    address private moderator = address(0xb);
    address private player1 = address(0xa);

    function setUp() public {
        spott = new Spott();
        address owner = spott.getOwner();
    }

    //     function test_Increment() public {
    //         counter.increment();
    //         assertEq(counter.number(), 1);
    //     }

    //     function testFuzz_SetNumber(uint256 x) public {
    //         counter.setNumber(x);
    //         assertEq(counter.number(), x);
    //     }
}
