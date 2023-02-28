
# Foundry Multichain 

This repo provides an example of a multichain Solidity Deployment/Upgradability script pattern. It can also be 
applicable for non-upgradable contracts (remove UUPSProxy)

- It uses CREATE2 to deploy Counter with UUPSProxy to multiple chains using a single Solidity script. 

- CREATE2 is used to preserve proxy addresses across multiple chains.

- Likewise, it uses a single Solidity script to upgrade contracts on multiple chains. 

Scripts are located at the __script__ directory:

- __BaseDeployer.s.sol__: Provides a base to the deploymeny & upgradability scripts. It includes all chains with their respective RPC urls (from foundry.toml)
- __Counter.s.sol__: Counter deployment script
- __CounterUpgrade.s.sol__: Counter upgreade script

Minimal set of tests are located at the __tests__ directory. 

__Before running anything, make sure your .env variables are set. You can use .env-example as a template__








## Things you can learn & get inspiration

- Multichain CREATE2 deploymnent 
- UUPS proxy setup and initialization 
- Multichain upgrades through UUPS proxy (preserving proxy address)
- Upgradability tests


## Running Tests

To build & run tests, run the following command

```bash
  forge test -vvvv 
```


## Examples

### Deploy to testnets 

- __deployCounterTestnet(uint256 \_counterSalt, uint256 \_counterProxySalt)__

```bash
forge script DeployCounter -s "deployCounterTestnet(uint256, uint256)" 5 6 --force --multi 
```
- add __--broadcast --verify__ to broadcast to network and verify contracts

### Deploy to selected chains
- __deployCounterSelectedChains(uint256 \_counterSalt, uint256 \_counterProxySalt, Chains[] calldata deployForks, Cycle cycle)__
```bash
forge script DeployCounter -s "deployCounterSelectedChains(uint256, uint256, uint8[] calldata, uint8)" 154 155 "[3,4,5,6]" 1 --force --multi 
```
- add __--broadcast --verify__ to broadcast to network and verify contracts
---

### Upgrade on testnets
- __upgradeTestnet()__

```bash
forge script UpgradeCounter -s "upgradeTestnet()" --force --multi

```
-  add __--broadcast --verify__ to broadcast to network and verify contracts

### Upgrade on selected chains

- __upgradeSelectedChains(Chains[] calldata upgradeForks, Cycle cycle)__
```bash
forge script UpgradeCounter -s "upgradeSelectedChains(uint8[] calldata, uint8)" "[3]" 1 --force --multi 
```
- add __--broadcast --verify__ to broadcast to network and verify contracts

## Acknowledgements

 - [OpenZeppelin Upgradeable Contracts With Foundry](https://github.com/jordaniza/OZ-Upgradeable-Foundry/awesome-readme)
## License

[MIT](https://choosealicense.com/licenses/mit/)

