// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/MyToken.sol";

contract MyTokenTest is Test {
    MyToken token;

    function setUp() public {
        token = new MyToken("Token1", "TK1", 1000);
    }

    function testMintedToDeployer() public view {
        assertEq(token.balanceOf(address(this)), 1000 * 10 ** 18);
    }
}