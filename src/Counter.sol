// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;
import {UUPSUpgradeable} from "openzeppelin-upgradeable/proxy/utils/UUPSUpgradeable.sol";

import {Initializable} from "openzeppelin-upgradeable/proxy/utils/Initializable.sol";

contract Counter is Initializable, UUPSUpgradeable {
    uint256 public number;
    address public owner;

    /* ========== ERRORS ========== */
    error NotOwner();

    /* ========== MODIFIERS ========== */

    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner();
        _;
    }

    /* ========== CONSTRUCTOR ========== */
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /* ========== FUNCTIONS ========== */

    function initialize(address _owner) public initializer {
        owner = _owner;
    }

    function setNumber(uint256 newNumber) public {
        number = newNumber;
    }

    /* ========== UUPS ========== */
    //solhint-disable-next-line no-empty-blocks
    function _authorizeUpgrade(address) internal override onlyOwner {}

    function getImplementation() external view returns (address) {
        return _getImplementation();
    }
}
