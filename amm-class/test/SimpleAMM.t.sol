// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/MyToken.sol";
import "../src/SimpleAMM.sol";

contract SimpleAMMTest is Test {
    MyToken tokenA;
    MyToken tokenB;
    SimpleAMM amm;

    address alice = address(0x1);

    function setUp() public {
        tokenA = new MyToken("Token1", "TK1", 10000);
        tokenB = new MyToken("Token2", "TK2", 10000);
        amm = new SimpleAMM(address(tokenA), address(tokenB));

        tokenA.transfer(alice, 1000 * 10 ** 18);
        tokenB.transfer(alice, 1000 * 10 ** 18);
    }

    function testAddLiquidity() public {
        vm.startPrank(alice);
        tokenA.approve(address(amm), 100 * 10 ** 18);
        tokenB.approve(address(amm), 100 * 10 ** 18);
        amm.addLiquidity(100 * 10 ** 18, 100 * 10 ** 18);
        vm.stopPrank();

        (uint256 r0, uint256 r1) = amm.getReserves();
        assertEq(r0, 100 * 10 ** 18);
        assertEq(r1, 100 * 10 ** 18);
        assertEq(amm.k(), r0 * r1);
    }

    function testSwapMaintainsInvariant() public {
        vm.startPrank(alice);
        tokenA.approve(address(amm), 100 * 10 ** 18);
        tokenB.approve(address(amm), 100 * 10 ** 18);
        amm.addLiquidity(100 * 10 ** 18, 100 * 10 ** 18);

        uint256 predictedOut = amm.getSwapAmountOut(10 * 10 ** 18, true);
        assertGt(predictedOut, 0);

        tokenA.approve(address(amm), 10 * 10 ** 18);
        amm.swap(10 * 10 ** 18, true);
        vm.stopPrank();

        (uint256 r0, uint256 r1) = amm.getReserves();
        uint256 oldK = 100 * 10 ** 18 * 100 * 10 ** 18;

        assertLe(r0 * r1, oldK);
        assertGt(tokenB.balanceOf(alice), 900 * 10 ** 18);
    }
}