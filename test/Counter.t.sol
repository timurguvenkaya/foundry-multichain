// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {Test} from "forge-std/Test.sol";
import {UUPSProxy} from "../src/UUPSProxy.sol";
import {Counter} from "../src/Counter.sol";
import {Counter2} from "./mocks/Counter2.sol";

/*solhint-disable func-name-mixedcase*/
contract CounterTest is Test {
    address private constant OWNER = 0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496;

    address private nonAdminAccount = makeAddr("nonAdminAccount");

    Counter private counterImpl;

    Counter private counter;
    Counter2 private counter2;

    UUPSProxy private proxyCounter;

    function setUp() public {
        counterImpl = new Counter();

        proxyCounter = new UUPSProxy(
            address(counterImpl),
            abi.encodeWithSelector(Counter.initialize.selector, OWNER)
        );

        counter = Counter(address(proxyCounter));

        counter.setNumber(20);
    }

    function test_setUp_alreadyInitialized_asProxy_reverts() public {
        vm.expectRevert("Initializable: contract is already initialized");
        counter.initialize(nonAdminAccount);
    }

    function test_setUp_alreadyInitialized_asImpl_reverts() public {
        vm.expectRevert("Initializable: contract is already initialized");
        counterImpl.initialize(nonAdminAccount);
    }

    function test_setUp_succeeds() public {
        assertEq(counter.owner(), OWNER, "Owner should be set");
        assertEq(counter.number(), 20, "Counter number should be 20");
        assertEq(counter.getImplementation(), address(counterImpl), "Implementation should be set");
    }

    function test_upgradeTo_notAdmin_reverts() public {
        Counter2 counterImpl2 = new Counter2();
        vm.prank(nonAdminAccount);

        vm.expectRevert(Counter.NotOwner.selector);
        counter.upgradeTo(address(counterImpl2));
    }

    function test_upgradeTo_succeeds() public {
        Counter2 counterImpl2 = new Counter2();

        counter.setNumber(50);

        assertEq(counter.number(), 50, "Counter number should be 50");

        counter.upgradeTo(address(counterImpl2));

        assertEq(
            counter.getImplementation(),
            address(counterImpl2),
            "Implementation should be upgraded"
        );

        counter2 = Counter2(address(proxyCounter));

        // State persists
        assertEq(counter2.number(), 50, "Counter number should be 50");
        assertEq(counter2.owner(), OWNER, "Owner should be set");

        counter2.setNumber(80);

        assertEq(counter2.number(), 80, "Counter number should be 80");
        counter2.setNumber2(100);

        assertEq(counter2.number2(), 100, "Counter2 number2 should be 100");

        assertEq(
            counter2.getImplementation(),
            address(counterImpl2),
            "Implementation should be upgraded"
        );
    }

    function test_setNumber_succeeds() public {
        counter.setNumber(3);
        assertEq(counter.number(), 3, "Counter number should be 3");
    }
}
