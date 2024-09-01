/*
forge script script/Join.s.sol:Join --rpc-url http://127.0.0.1:3000/ --broadcast -vvv --legacy --slow
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/TreasureHunt.sol";

contract Join is Script {
    TreasureHunt treasureHunt =TreasureHunt(0x222c21111dDde68e6eaC2fCde374761E72c45FFe);
    function run() external {
        // Define the player address and initial ETH balance

        string memory seedPhrase = vm.readFile(".secret");
        uint256 privateKey = vm.deriveKey(seedPhrase, 1);
        address player=vm.addr(privateKey);
        // Start broadcasting transactions
        vm.startBroadcast(privateKey);

        treasureHunt.joinGame{value:1e15}();

        // Get the player's initial position
        uint8 initialPosition = treasureHunt.playerPositions(player);
        console.log("Player initial position:", initialPosition);

        // // Move to a new position (assuming an adjacent position for simplicity)
        // uint8 newPosition = (initialPosition + 1) % 100; // Example: move to the next position
        // treasureHunt.move{value: 1e14}(newPosition);

        // // Get the player's new position
        // uint8 updatedPosition = treasureHunt.playerPositions(player);
        // console.log("Player new position:", updatedPosition);

        // Stop broadcasting transactions
        vm.stopBroadcast();
    }
}