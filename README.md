Project consists **TreasureHunt.sol** contract in src folder along with its tester contract.

## Test Using following command

```shell
$ forge test --match-path test/TreasureHunt.t.sol -vvv
```


## Deploy to Fork (Can replace rpc with any chain rpc)

```shell
$ forge script script/DeployTreasureHunt.s.sol:DeployTreasureHunt --rpc-url http://127.0.0.1:3000/ --broadcast -vvv --legacy --slow
```

## About Game
### Randomness:
  Initial Treasure Position: The initial treasure position is determined using the block number hash.
  Player Initial Position: Players are assigned a random initial position based on the block timestamp, block number, and their address.
  Treasure Movement: The treasure moves to a new position based on certain conditions (prime number or multiple of five) using the block timestamp and previous block's random number.

### Game Mechanics:
  Joining the Game: Players join the game by sending a minimum amount of ETH (minJoinAmount). This ensures commitment and adds to the game balance.
  Moving: Players can move to adjacent positions by sending a minimum move amount (minMoveAmount). This adds to the game balance and triggers potential treasure movement.
