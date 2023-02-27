// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

import {Script} from "forge-std/Script.sol";
import {Counter} from "../src/Counter.sol";

import {BaseDeployer} from "./BaseDeployer.s.sol";

import {UUPSProxy} from "../src/UUPSProxy.sol";

/* solhint-disable no-console*/
import {console2} from "forge-std/console2.sol";

contract DeployCounter is Script, BaseDeployer {
    address create2addrCounter;
    address create2addrProxy;

    Counter private wrappedProxy;

    /// @dev Compute the CREATE2 addresses for contracts (proxy, counter).
    /// @param saltCounter The salt for the counter contract.
    /// @param saltProxy The salt for the proxy contract.
    modifier computeCreate2(bytes32 saltCounter, bytes32 saltProxy) {
        create2addrCounter = computeCreate2Address(
            saltCounter,
            hashInitCode(type(Counter).creationCode)
        );

        create2addrProxy = computeCreate2Address(
            saltProxy,
            hashInitCode(
                type(UUPSProxy).creationCode,
                abi.encode(
                    create2addrCounter,
                    abi.encodeWithSelector(Counter.initialize.selector, ownerAddress)
                )
            )
        );

        _;
    }

    /// @dev Deploy contracts to mainnet.
    function deployCounterMainnet() external setEnvDeploy(Cycle.Prod) {
        Chains[] memory deployForks = new Chains[](8);

        counterSalt = bytes32(uint256(10));
        counterProxySalt = bytes32(uint256(11));

        deployForks[0] = Chains.Etherum;
        deployForks[1] = Chains.Polygon;
        deployForks[2] = Chains.Bsc;
        deployForks[3] = Chains.Avalanche;
        deployForks[4] = Chains.Arbitrum;
        deployForks[5] = Chains.Optimism;
        deployForks[6] = Chains.Moonbeam;
        deployForks[7] = Chains.Astar;

        createDeployMultichain(deployForks);
    }

    /// @dev Deploy contracts to testnet.
    function deployCounterTestnet(
        uint256 _counterSalt,
        uint256 _counterProxySalt
    ) public setEnvDeploy(Cycle.Test) {
        Chains[] memory deployForks = new Chains[](8);

        counterSalt = bytes32(_counterSalt);
        counterProxySalt = bytes32(_counterProxySalt);

        deployForks[0] = Chains.Goerli;
        deployForks[1] = Chains.Mumbai;
        deployForks[2] = Chains.BscTest;
        deployForks[3] = Chains.Fuji;
        deployForks[4] = Chains.ArbitrumGoerli;
        deployForks[5] = Chains.OptimismGoerli;
        deployForks[6] = Chains.Shiden;
        deployForks[7] = Chains.Moonriver;

        createDeployMultichain(deployForks);
    }

    /// @dev Deploy contracts to local.
    function deployCounterLocal() external setEnvDeploy(Cycle.Dev) {
        Chains[] memory deployForks = new Chains[](3);
        counterSalt = bytes32(uint256(1));
        counterProxySalt = bytes32(uint256(2));

        deployForks[0] = Chains.LocalGoerli;
        deployForks[1] = Chains.LocalFuji;
        deployForks[2] = Chains.LocalBSCTest;

        createDeployMultichain(deployForks);
    }

    /// @dev Deploy contracts to selected chains.
    /// @param _counterSalt The salt for the counter contract.
    /// @param _counterProxySalt The salt for the proxy contract.
    /// @param deployForks The chains to deploy to.
    /// @param cycle The development cycle to set env variables (dev, test, prod).
    function deployCounterSelectedChains(
        uint256 _counterSalt,
        uint256 _counterProxySalt,
        Chains[] calldata deployForks,
        Cycle cycle
    ) external setEnvDeploy(cycle) {
        counterSalt = bytes32(_counterSalt);
        counterProxySalt = bytes32(_counterProxySalt);

        createDeployMultichain(deployForks);
    }

    /// @dev Helper to iterate over chains and select fork.
    /// @param deployForks The chains to deploy to.
    function createDeployMultichain(
        Chains[] memory deployForks
    ) private computeCreate2(counterSalt, counterProxySalt) {
        console2.log("Counter create2 address:", create2addrCounter, "\n");
        console2.log("Counter proxy create2 address:", create2addrProxy, "\n");

        for (uint256 i; i < deployForks.length; ) {
            console2.log("Deploying Counter to chain: ", uint(deployForks[i]), "\n");

            createSelectFork(deployForks[i]);

            chainDeployCounter();

            unchecked {
                ++i;
            }
        }
    }

    /// @dev Function to perform actual deployment.
    function chainDeployCounter() private broadcast(deployerPrivateKey) {
        Counter counter = new Counter{salt: counterSalt}();

        require(create2addrCounter == address(counter), "Address mismatch Counter");

        console2.log("Counter address:", address(counter), "\n");

        proxyCounter = new UUPSProxy{salt: counterProxySalt}(
            address(counter),
            abi.encodeWithSelector(Counter.initialize.selector, ownerAddress)
        );

        proxyCounterAddress = address(proxyCounter);

        require(create2addrProxy == proxyCounterAddress, "Address mismatch ProxyCounter");

        wrappedProxy = Counter(proxyCounterAddress);

        require(wrappedProxy.owner() == ownerAddress, "Owner role mismatch");

        console2.log("Counter Proxy address:", address(proxyCounter), "\n");
    }
}
