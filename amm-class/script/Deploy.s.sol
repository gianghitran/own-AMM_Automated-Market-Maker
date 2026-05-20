 // SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../src/MyToken.sol";
import "../src/SimpleAMM.sol";

contract DeployScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        MyToken tokenA = new MyToken("Token1", "TK1", 10000);
        MyToken tokenB = new MyToken("Token2", "TK2", 10000);
        SimpleAMM amm = new SimpleAMM(address(tokenA), address(tokenB));

        vm.stopBroadcast();
    }
}