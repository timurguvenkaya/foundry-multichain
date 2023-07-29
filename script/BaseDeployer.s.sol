// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {Script} from "forge-std/Script.sol";
import {UUPSProxy} from "../src/UUPSProxy.sol";

/* solhint-disable max-states-count */
contract BaseDeployer is Script {
    UUPSProxy internal proxyCounter;

    bytes32 internal counterProxySalt;
    bytes32 internal counterSalt;

    uint256 internal deployerPrivateKey;

    address internal ownerAddress;
    address internal proxyCounterAddress;

    enum Chains {
        LocalGoerli,
        LocalFuji,
        LocalBSCTest,
        Goerli,
        Mumbai,
        BscTest,
        Fuji,
        ArbitrumGoerli,
        OptimismGoerli,
        Moonriver,
        Shiden,
        ethereum,
        Polygon,
        Bsc,
        Avalanche,
        Arbitrum,
        Optimism,
        Moonbeam,
        Astar
    }

    enum Cycle {
        Dev,
        Test,
        Prod
    }

    /// @dev Mapping of chain enum to rpc url
    mapping(Chains chains => string rpcUrls) public forks;

    /// @dev environment variable setup for deployment
    /// @param cycle deployment cycle (dev, test, prod)
    modifier setEnvDeploy(Cycle cycle) {
        if (cycle == Cycle.Dev) {
            deployerPrivateKey = vm.envUint("LOCAL_DEPLOYER_KEY");
            ownerAddress = vm.envAddress("LOCAL_OWNER_ADDRESS");
        } else if (cycle == Cycle.Test) {
            deployerPrivateKey = vm.envUint("TEST_DEPLOYER_KEY");
            ownerAddress = vm.envAddress("TEST_OWNER_ADDRESS");
        } else {
            deployerPrivateKey = vm.envUint("DEPLOYER_KEY");
            ownerAddress = vm.envAddress("OWNER_ADDRESS");
        }

        _;
    }

    /// @dev environment variable setup for upgrade
    /// @param cycle deployment cycle (dev, test, prod)
    modifier setEnvUpgrade(Cycle cycle) {
        if (cycle == Cycle.Dev) {
            deployerPrivateKey = vm.envUint("LOCAL_DEPLOYER_KEY");
            proxyCounterAddress = vm.envAddress("LOCAL_COUNTER_PROXY_ADDRESS");
        } else if (cycle == Cycle.Test) {
            deployerPrivateKey = vm.envUint("TEST_DEPLOYER_KEY");
            proxyCounterAddress = vm.envAddress("TEST_COUNTER_PROXY_ADDRESS");
        } else {
            deployerPrivateKey = vm.envUint("DEPLOYER_KEY");
            proxyCounterAddress = vm.envAddress("COUNTER_PROXY_ADDRESS");
        }

        _;
    }

    /// @dev broadcast transaction modifier
    /// @param pk private key to broadcast transaction
    modifier broadcast(uint256 pk) {
        vm.startBroadcast(pk);

        _;

        vm.stopBroadcast();
    }

    constructor() {
        // Local
        forks[Chains.LocalGoerli] = "localGoerli";
        forks[Chains.LocalFuji] = "localFuji";
        forks[Chains.LocalBSCTest] = "localBSCTest";

        // Testnet
        forks[Chains.Goerli] = "goerli";
        forks[Chains.Mumbai] = "mumbai";
        forks[Chains.BscTest] = "bsctest";
        forks[Chains.Fuji] = "fuji";
        forks[Chains.ArbitrumGoerli] = "arbitrumgoerli";
        forks[Chains.OptimismGoerli] = "optimismgoerli";
        forks[Chains.Moonriver] = "moonriver";
        forks[Chains.Shiden] = "shiden";

        // Mainnet
        forks[Chains.ethereum] = "ethereum";
        forks[Chains.Polygon] = "polygon";
        forks[Chains.Bsc] = "bsc";
        forks[Chains.Avalanche] = "avalanche";
        forks[Chains.Arbitrum] = "arbitrum";
        forks[Chains.Optimism] = "optimism";
        forks[Chains.Moonbeam] = "moonbeam";
        forks[Chains.Astar] = "astar";
    }

    function createFork(Chains chain) public {
        vm.createFork(forks[chain]);
    }

    function createSelectFork(Chains chain) public {
        vm.createSelectFork(forks[chain]);
    }
}
