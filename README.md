## Info
This branch is used for testing consensus of cometbft under the circumstances of special task

## Task

Fork Cosmos SDK, modify protocol logic and launch a local network with 10 nodes.
1. Fork cosmos sdk: https://github.com/cosmos/cosmos-sdk 2. Modify the related code or components to:
a. Add a new field in the block data structure which can record a specific block number.
b. Modify the block proposal and verification logic so:
i. The leader, when proposing a new block, will call a Ethereum rpc server and get the latest eth block number and add that number in the new field mentioned above.
ii. The validators will do the same rpc call to verify that the latest ethereum block number is greater or equal to the number in the proposed block. If true, sign the block, otherwise, reject the block.
3. Launch the modified protocol network with 10 nodes and test following scenarios:
a. All nodes talk to the same rpc server and they can reach consensus succesfully.
b. 5 nodes talk to normal rpc server while the rest talk to a bad rpc server which report block number that’s way smaller. This will cause the consensus failure since only 50% of the nodes agree with each other.

## Solution

### Config
`devnet.yaml`:
```yaml
exocore:
  cmd: good-simd
  validators:
    - coins: 1000000000000000000stake
      staked: 1000000000000000000stake
      mnemonic: reduce topple fish ordinary nut rubber stomach kite tooth entire warfare immense
    - coins: 1000000000000000000stake
      staked: 1000000000000000000stake
      mnemonic: oyster sense buffalo awake narrow run glue devote wedding cheap split dove
    - coins: 1000000000000000000stake
      staked: 1000000000000000000stake
      mnemonic: spoil citizen dignity web flush cabbage east dune culture cliff twenty key
    - coins: 1000000000000000000stake
      staked: 1000000000000000000stake
      mnemonic: decrease saddle opinion fossil armed intact luggage donor chalk genre monitor crystal
    - coins: 1000000000000000000stake
      staked: 1000000000000000000stake
      mnemonic: distance certain bitter wrap town benefit poet remember punch practice rocket primary
    - coins: 1000000000000000000stake
      staked: 1000000000000000000stake
      mnemonic: actor sleep dinosaur fork tide infant quote unique razor vintage denial clutch
    - coins: 1000000000000000000stake
      staked: 1000000000000000000stake
      mnemonic: matrix acid rescue warm crawl grocery tooth material marine nice task three
    - coins: 1000000000000000000stake
      staked: 1000000000000000000stake
      mnemonic: era mean fold install violin dust once language gadget sense program deer
    - coins: 1000000000000000000stake
      staked: 1000000000000000000stake
      mnemonic: split brick brain box strong main bullet multiply oyster south copper tiger
    - coins: 1000000000000000000stake
      staked: 1000000000000000000stake
      mnemonic: omit voyage cactus behave riot various sphere dwarf deposit survey inmate remind
  accounts:
    - name: community
      coins: 10000000000000000000000stake
      mnemonic: tooth flower auto verb furnace junior retire boy life upon salt light
    - name: signer1
      coins: 20000000000000000000000stake
      mnemonic: crop capable senior worry now that horse hover vehicle silk mutual govern
    - name: signer2
      coins: 30000000000000000000000stake
      mnemonic: rare fold jump soccer long bonus churn drift real metal exotic copy

  genesis:  # patch genesis states
    consensus_params:
      block:
        max_bytes: "1048576"
        max_gas: "81500000"
    app_state:
      staking:
        params:
          unbonding_time: "10s"
```

### Procedures

1. install `pystarport`, which is our scaffold used to start the local testnet with 10 nodes:
```bash
python3 -m pip install pystarport
```

2. pull forked upstream cometbft repo, which has changed the `Block` data struct and some consensus logics:
```bash
git pull https://github.com/adu-web3/cometbft.git
```

3. checkout to `exocore-test` branch:
```bash
git checkout exocore-test
```

4. pull this repo and checkout to `exocore-test` branch:
```bash
git pull https://github.com/adu-web3/cosmos-sdk.git
git checkout exocore-test
```

5. replace `tendermint` dependency path with your local `cometbft` repo path in `go.mod` file of your locak cosmo-sdk repo:
```go
replace (
	// use cosmos fork of keyring
	github.com/99designs/keyring => github.com/cosmos/keyring v1.2.0
	....
	// use cometbft
	github.com/tendermint/tendermint => ${your-local-cometbft-repo-path}
)
```

6. compile and install misbehaved `simd`:
```bash
cd cosmos-sdk
make install
mv ~/go/bin/simd ~/go/bin/bad-simd
```

7. checkout `cometbft` repo to `exocore-test-good` branch, which listens to normal ethereum oracle rpc and respond correctly:
```bash
cd cometbft
git checkout exocore-test-good
```

8. compile and install well-behaved `simd`:
```bash
cd cosmos-sdk
make install
mv ~/go/bin/simd ~/go/bin/good-simd
```

9. start the network with 10 well-behaved nodes:
```bash
pystarport init --config tmp/devnet.yaml
pystarport start --data data > tmp/log.txt
```

10. start the network with 5 well-behaved nodes and 5 misbehaved nodes:
```bash
pystarport init --config tmp/devnet.yaml
```
then edit `tasks.ini` in `data/exocore/` to specify the command for each node to have 5
nodes running `good-simd` and the rest running `bad-simd`
```bash
pystarport start --data data > tmp/log.txt
```

### Doubts and follows

If we run a local testnet with with 5 well-behaved nodes and 5 misbehaved nodes, the expected consensus failure
does not halt the network, instead the network would continue infinite rounds of prevote until another proposal 
was created and successfully validated at the same block height.

About this problem, I have open an issue to discuss and follow the future solutions:
https://github.com/cometbft/cometbft/issues/1172