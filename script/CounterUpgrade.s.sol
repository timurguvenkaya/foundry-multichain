// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

import {Script} from "forge-std/Script.sol";
import {Counter} from "../src/Counter.sol";
import {BaseDeployer} from "./BaseDeployer.s.sol";

/* solhint-disable no-console*/
import {console2} from "forge-std/console2.sol";

contract UpgradeCounter is Script, BaseDeployer {
    Counter private wrappedProxy;

    /// @dev Upgrade contracts on mainnet.
    function upgradeMainnet() external setEnvUpgrade(Cycle.Prod) {
        Chains[] memory upgradeForks = new Chains[](8);

        upgradeForks[0] = Chains.Etherum;
        upgradeForks[1] = Chains.Polygon;
        upgradeForks[2] = Chains.Bsc;
        upgradeForks[3] = Chains.Avalanche;
        upgradeForks[4] = Chains.Arbitrum;
        upgradeForks[5] = Chains.Optimism;
        upgradeForks[6] = Chains.Moonbeam;
        upgradeForks[7] = Chains.Astar;

        createUpgradeMultichainCounter(upgradeForks);
    }

    /// @dev Upgrade contracts on testnet.
    function upgradeTestnet() external setEnvUpgrade(Cycle.Test) {
        Chains[] memory upgradeForks = new Chains[](8);

        upgradeForks[0] = Chains.Goerli;
        upgradeForks[1] = Chains.Mumbai;
        upgradeForks[2] = Chains.BscTest;
        upgradeForks[3] = Chains.Fuji;
        upgradeForks[4] = Chains.ArbitrumGoerli;
        upgradeForks[5] = Chains.OptimismGoerli;
        upgradeForks[6] = Chains.Moonriver;
        upgradeForks[7] = Chains.Shiden;

        createUpgradeMultichainCounter(upgradeForks);
    }

    /// @dev Upgrade contracts on local.
    function upgradeLocal() external setEnvUpgrade(Cycle.Dev) {
        Chains[] memory upgradeForks = new Chains[](3);

        upgradeForks[0] = Chains.LocalGoerli;
        upgradeForks[1] = Chains.LocalFuji;
        upgradeForks[2] = Chains.LocalBSCTest;

        createUpgradeMultichainCounter(upgradeForks);
    }

    /// @dev Upgrade contracts on selected chains.
    /// @param upgradeForks The chains to upgrade.
    /// @param cycle The development cycle to set env variables (dev, test, prod).
    function upgradeSelectedChains(
        Chains[] calldata upgradeForks,
        Cycle cycle
    ) external setEnvUpgrade(cycle) {
        createUpgradeMultichainCounter(upgradeForks);
    }

    /// @dev Helper to iterate over chains and select forks.
    /// @param upgradeForks The chains to upgrade.
    function createUpgradeMultichainCounter(Chains[] memory upgradeForks) private {
        for (uint256 i; i < upgradeForks.length; ) {
            console2.log("Upgrading Counter on fork: ", uint(upgradeForks[i]));

            createSelectFork(upgradeForks[i]);

            chainUpgradeCounter();

            unchecked {
                ++i;
            }
        }
    }

    /// @dev Perform uprade on selected chain.
    function chainUpgradeCounter() private broadcast(deployerPrivateKey) {
        //solhint-disable-next-line no-unused-vars
        Counter counter = new Counter();

        wrappedProxy = Counter(proxyCounterAddress);

        wrappedProxy.upgradeTo(address(counter));
    }
}
