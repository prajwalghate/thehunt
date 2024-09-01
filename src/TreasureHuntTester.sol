// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../src/TreasureHunt.sol";

contract TreasureHuntTester is TreasureHunt {
    function setTreasurePosition(uint8 position) external {
        treasurePosition = position;
    }

    function setPlayerPosition(address player, uint8 position) external {
        playerPositions[player] = position;
    }
}