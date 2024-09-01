// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/TreasureHunt.sol";
import "../src/TreasureHuntTester.sol";

contract TreasureHuntTest is Test {
    TreasureHunt treasureHunt;
    TreasureHuntTester treasureHuntTester;
    address player1 = address(0x1);
    address player2 = address(0x2);

    function setUp() public {
        treasureHunt = new TreasureHunt();
        treasureHuntTester = new TreasureHuntTester();
    }

    function test_InitialTreasurePosition() public {
        uint256 initialPosition = treasureHunt.treasurePosition();
        console.log("initialPosition", initialPosition);
        assertTrue(initialPosition < 100, "Initial treasure position should be within grid bounds");
    }

    function test_InitialTreasurePositionIsRandom() public {
        uint256[] memory positions = new uint256[](5);
        for (uint256 i = 0; i < 5; i++) {
            vm.roll(block.number + i); // Change block number every time
            treasureHunt = new TreasureHunt();
            positions[i] = treasureHunt.treasurePosition();
        }

        bool allSame = true;
        for (uint256 i = 1; i < positions.length; i++) {
            if (positions[i] != positions[0]) {
                allSame = false;
                break;
            }
        }

        assertFalse(allSame, "Initial treasure position should be random");
    }

    function test_IsAdjacent() public {
        // Test adjacent positions
        assertTrue(treasureHunt.isAdjacent(0, 1), "Position 0 and 1 should be adjacent");
        assertTrue(treasureHunt.isAdjacent(1, 0), "Position 1 and 0 should be adjacent");
        assertTrue(treasureHunt.isAdjacent(0, 10), "Position 0 and 10 should be adjacent");
        assertTrue(treasureHunt.isAdjacent(10, 0), "Position 10 and 0 should be adjacent");
        assertTrue(treasureHunt.isAdjacent(11, 10), "Position 11 and 10 should be adjacent");
        assertTrue(treasureHunt.isAdjacent(55, 65), "Position 55 and 65 should be adjacent");

        // Test non-adjacent positions
        assertFalse(treasureHunt.isAdjacent(0, 2), "Position 0 and 2 should not be adjacent");
        assertFalse(treasureHunt.isAdjacent(0, 20), "Position 0 and 20 should not be adjacent");
        assertFalse(treasureHunt.isAdjacent(5, 1), "Position 5 and 1 should not be adjacent");
        assertFalse(treasureHunt.isAdjacent(9, 18), "Position 9 and 18 should not be adjacent");
    }

    function test_GetRandomAdjacentPosition(uint8 position) public {
        vm.assume(position >= 0 && position <= 99);
        uint8 randomAdjacentPosition = treasureHunt.getRandomAdjacentPosition(position);
        
        // Check that the random adjacent position is indeed adjacent
        bool isAdjacent = treasureHunt.isAdjacent(position, randomAdjacentPosition);
        assertTrue(isAdjacent, "The random adjacent position should be adjacent to the original position");
    }

    function test_JoinGame() public {
        vm.deal(player1, 1 ether);
        vm.startPrank(player1);
        treasureHunt.joinGame{value: 0.01 ether}();
        uint8 playerPosition = treasureHunt.playerPositions(player1);
        assertTrue(playerPosition < 100, "Player1 should have a valid initial position");
        assertEq(treasureHunt.gameBalance(), 0.01 ether, "Game balance should be 0.01 ether");
        vm.stopPrank();
    }

    function test_JoinGameWithoutETH() public {
        vm.startPrank(player1);
        vm.expectRevert("Must send at least the minimum join amount");
        treasureHunt.joinGame();
        vm.stopPrank();
    }

    function test_MoveWithETH() public {
        vm.deal(player1, 1 ether);
        vm.startPrank(player1);
        treasureHunt.joinGame{value: 0.01 ether}();
        uint8 currentPosition = treasureHunt.playerPositions(player1);
        uint8 newPosition = treasureHunt.getRandomAdjacentPosition(currentPosition);
        treasureHunt.move{value: 0.001 ether}(newPosition);
        assertEq(treasureHunt.playerPositions(player1), newPosition, "Player1 should be at the new adjacent position");
        assertEq(treasureHunt.gameBalance(), 0.011 ether, "Game balance should be 0.011 ether");
        vm.stopPrank();
    }

    function test_MoveWithoutETH() public {
        vm.deal(player1, 1 ether);
        vm.startPrank(player1);
        treasureHunt.joinGame{value: 0.01 ether}();
        vm.expectRevert("Must send at least the minimum move amount");
        treasureHunt.move(1);
        vm.stopPrank();
    }

    function test_MoveToInvalidPosition() public {
        vm.deal(player1, 1 ether);
        vm.startPrank(player1);
        treasureHunt.joinGame{value: 0.01 ether}();
        vm.expectRevert("Invalid position");
        treasureHunt.move{value: 0.001 ether}(100);
        vm.stopPrank();
    }

    function test_MoveToNonAdjacentPosition() public {
        vm.deal(player1, 1 ether);
        vm.startPrank(player1);
        treasureHunt.joinGame{value: 0.01 ether}();
        vm.expectRevert("Move must be to an adjacent position");
        treasureHunt.move{value: 0.001 ether}(1);
        vm.stopPrank();
    }

    function test_MoveOnPrimePosition() public {
        vm.deal(player1, 1 ether);
        vm.startPrank(player1);
        treasureHuntTester.joinGame{value: 0.01 ether}();
        treasureHuntTester.setPlayerPosition(player1, 1); // Set player1 to position 1
        uint256 oldTreasurePosition = treasureHuntTester.treasurePosition();
        treasureHuntTester.move{value: 0.001 ether}(2); // Move to position 2, which is a prime number
        uint256 newTreasurePosition = treasureHuntTester.treasurePosition();
        assertTrue(newTreasurePosition < 100, "Treasure position should be within grid bounds");
        assertTrue(newTreasurePosition != oldTreasurePosition, "Treasure position should have changed");
        vm.stopPrank();
    }


    function test_MoveOnMultipleOfFive() public {
        vm.deal(player1, 1 ether);
        vm.startPrank(player1);
        treasureHuntTester.joinGame{value: 0.01 ether}();
        treasureHuntTester.setPlayerPosition(player1, 4); // Set player1 to position 4
        uint256 oldTreasurePosition = treasureHuntTester.treasurePosition();
        treasureHuntTester.move{value: 0.001 ether}(5); // Move to position 5, which is a multiple of 5
        uint256 newTreasurePosition = treasureHuntTester.treasurePosition();
        assertTrue(newTreasurePosition < 100, "Treasure position should be within grid bounds");
        assertTrue(newTreasurePosition != oldTreasurePosition, "Treasure position should have changed");
        assertTrue(treasureHuntTester.isAdjacent(uint8(oldTreasurePosition), uint8(newTreasurePosition)), "Treasure should move to an adjacent position");
        vm.stopPrank();
    }

    
}