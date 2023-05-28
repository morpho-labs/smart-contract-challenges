// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// Inspired from https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/proxy/Proxy.sol
contract Proxy {
    address internal admin;
    address internal implementation;

    constructor() {
        admin = msg.sender;
    }

    /// @dev Delegates the current call to `implementation`.
    /// @dev This function does not return to its internal call site, it will return directly to the external caller.
    function _delegate(address implementationUsed) internal virtual {
        assembly {
            // Copy msg.data. We take full control of memory in this inline assembly
            // block because it will not return to Solidity code. We overwrite the
            // Solidity scratch pad at memory position 0.
            calldatacopy(0, 0, calldatasize())

            // Call the implementation.
            // out and outsize are 0 because we don't know the size yet.
            let result := delegatecall(gas(), implementationUsed, 0, calldatasize(), 0, 0)

            // Copy the returned data.
            returndatacopy(0, 0, returndatasize())

            switch result
            // delegatecall returns 0 on error.
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }

    /// @dev Returns the current implementation address.
    function getImplementation() external view returns (address) {
        return implementation;
    }

    /// @dev Stores a new address in the EIP1967 implementation slot.
    function setImplementation(address newImplementation) external {
        require(newImplementation.code.length > 0, "new implementation is not a contract");
        require(admin == msg.sender);
        implementation = newImplementation;
    }

    /// @dev Delegates the current call to the address returned by `_implementation()`.
    /// @dev This function does not return to its internal call site, it will return directly to the external caller.
    function _fallback() internal virtual {
        _delegate(implementation);
    }

    /// @dev Fallback function that delegates calls to the address returned by `_implementation()`. Will run if no other function in the contract matches the call data.

    fallback() external payable virtual {
        _fallback();
    }

    /// @dev Fallback function that delegates calls to the address returned by `_implementation()`. Will run if call data is empty.
    receive() external payable virtual {
        _fallback();
    }
}
