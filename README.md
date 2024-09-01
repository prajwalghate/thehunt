Project consists **TreasureHunt.sol** contract in src folder along with its tester contract.
The randomness is handled using the keccak256 hash function combined with various sources including block number , timpestamp and address.

### Test Using following command

```shell
$ forge test --match-path test/TreasureHunt.t.sol -vvv
```


### Deploy to Fork (Can replace rpc with any chain rpc)

```shell
$ forge script script/DeployTreasureHunt.s.sol:DeployTreasureHunt --rpc-url http://127.0.0.1:3000/ --broadcast -vvv --legacy --slow
```


