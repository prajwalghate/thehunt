
/*
forge script script/DeployTreasureHunt.s.sol:DeployTreasureHunt --rpc-url http://127.0.0.1:3000/ --broadcast -vvv --legacy --slow
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "forge-std/Script.sol";
import "../src/TreasureHunt.sol";

contract DeployTreasureHunt is Script {


    function run() external {

        string memory seedPhrase = vm.readFile(".secret");
        uint256 privateKey = vm.deriveKey(seedPhrase, 0);
        
        vm.startBroadcast(privateKey);

        // Deploy the TreasureHunt contract
        TreasureHunt treasureHunt = new TreasureHunt();

        vm.stopBroadcast();

        // Log the address of the deployed contract
        console.log("TreasureHunt deployed at:", address(treasureHunt));
    }
}

