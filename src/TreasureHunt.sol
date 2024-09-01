/*
Run test using the below command
forge test --match-path test/TreasureHunt.t.sol -vvv
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TreasureHunt {
    uint8 constant GRID_SIZE = 10;
    uint8 constant GRID_AREA = GRID_SIZE * GRID_SIZE;
    uint256 public treasurePosition;
    address public winner;
    uint256 public gameBalance;
    address public owner;
    uint256 public minJoinAmount = 1e15;
    uint256 public minMoveAmount = 1e14;
    bool public gameRunning;

    uint8[] public primeNumbers = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97];
    address[] public players;

    mapping(address => uint8) public playerPositions;

    event PlayerJoined(address indexed player, uint8 initialPosition);
    event PlayerMoved(address indexed player, uint8 newPosition);
    event TreasureMoved(uint8 newPosition);
    event GameWon(address indexed winner, uint256 reward);
    event GameRestarted();

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    modifier gameIsRunning() {
        require(gameRunning, "Game is not running");
        _;
    }

    constructor() {
        owner = msg.sender;
        initGame();
    }

    function initGame() internal {
        // Initialize the treasure position based on the block number hash
        treasurePosition = uint8(uint256(keccak256(abi.encodePacked(block.number))) % GRID_AREA);
        winner = address(0);
        gameBalance = 0;
        gameRunning = true;
    }

    function joinGame() external payable gameIsRunning {
        require(msg.value >= minJoinAmount, "Must send at least the minimum join amount");
        require(playerPositions[msg.sender] == 0, "Player already joined");

        playerPositions[msg.sender] = uint8(uint256(keccak256(abi.encodePacked(block.timestamp,block.number, msg.sender))) % GRID_AREA);
        players.push(msg.sender);
        gameBalance += msg.value;

        emit PlayerJoined(msg.sender, playerPositions[msg.sender]);
    }

    function move(uint8 newPosition) external payable gameIsRunning {
        require(msg.value >= minMoveAmount, "Must send at least the minimum move amount");
        require(newPosition < GRID_AREA, "Invalid position");
        require(isAdjacent(playerPositions[msg.sender], newPosition), "Move must be to an adjacent position");

        playerPositions[msg.sender] = newPosition;
        gameBalance += msg.value;

        shiftTreasure(newPosition);

        if (newPosition == treasurePosition) {
            winner = msg.sender;
            uint256 reward = (gameBalance * 90) / 100;
            payable(winner).transfer(reward);
            gameBalance -= reward;
            gameRunning = false;
            emit GameWon(winner, reward);
        }
        emit PlayerMoved(msg.sender, newPosition);
    }

    function restartGame() external onlyOwner {
        require(!gameRunning, "Game is still running");

        // Clear player positions
        for (uint256 i = 0; i < players.length; i++) {
            delete playerPositions[players[i]];
        }
        delete players;

        initGame();
        emit GameRestarted();
    }

    function isAdjacent(uint8 currentPosition, uint8 newPosition) public pure returns (bool) {
        int8 x1 = int8(currentPosition % GRID_SIZE);
        int8 y1 = int8(currentPosition / GRID_SIZE);
        int8 x2 = int8(newPosition % GRID_SIZE);
        int8 y2 = int8(newPosition / GRID_SIZE);

        return (abs(x1 - x2) + abs(y1 - y2)) == 1;
    }

    function abs(int8 x) internal pure returns (int8) {
        return x >= 0 ? x : -x;
    }

    function shiftTreasure(uint8 playerPosition) internal {
        if (playerPosition % 5 == 0) {
            treasurePosition = getRandomAdjacentPosition(uint8(treasurePosition));
        } else if (isPrime(playerPosition)) {
            treasurePosition = uint8(uint256(keccak256(abi.encodePacked(block.timestamp, block.prevrandao))) % GRID_AREA);
        }
        emit TreasureMoved(uint8(treasurePosition));
    }

    function isPrime(uint8 num) internal view returns (bool) {
        uint8[] memory primes = primeNumbers; // Make a local copy of the prime numbers array
        for (uint8 i = 0; i < primes.length; i++) {
            if (primes[i] == num) {
                return true;
            }
        }
        return false;
    }

    function getRandomAdjacentPosition(uint8 position) public view returns (uint8) {
        uint8[4] memory possibleMoves;
        uint8 count = 0;

        if (position % GRID_SIZE > 0) possibleMoves[count++] = position - 1; // left
        if (position % GRID_SIZE < GRID_SIZE - 1) possibleMoves[count++] = position + 1; // right
        if (position / GRID_SIZE > 0) possibleMoves[count++] = position - GRID_SIZE; // up
        if (position / GRID_SIZE < GRID_SIZE - 1) possibleMoves[count++] = position + GRID_SIZE; // down

        return possibleMoves[uint8(uint256(keccak256(abi.encodePacked(block.timestamp, block.prevrandao))) % count)];
    }
}