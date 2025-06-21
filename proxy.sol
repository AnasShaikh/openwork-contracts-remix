// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

/**
 * @title GenericUUPSProxy
 * @dev Generic proxy contract for any UUPS upgradeable contract
 */
contract GenericUUPSProxy is ERC1967Proxy {
    constructor(
        address implementation,
        bytes memory _data
    ) ERC1967Proxy(implementation, _data) {}
}

/**
 * @title GenericProxyDeployer
 * @dev Helper contract to deploy proxies for any contract with any initialization data
 */
contract GenericProxyDeployer {
    event ProxyDeployed(address indexed proxy, address indexed implementation);
    
    /**
     * @dev Deploy a proxy with custom initialization data
     * @param implementation Address of the implementation contract
     * @param initData Encoded initialization function call
     */
    function deployProxy(
        address implementation,
        bytes calldata initData
    ) external returns (address) {
        // Deploy the proxy
        GenericUUPSProxy proxy = new GenericUUPSProxy(
            implementation,
            initData
        );
        
        emit ProxyDeployed(address(proxy), implementation);
        return address(proxy);
    }
    
    /**
     * @dev Deploy a proxy without initialization (for contracts with no initializer)
     * @param implementation Address of the implementation contract
     */
    function deployProxyWithoutInit(
        address implementation
    ) external returns (address) {
        // Deploy the proxy with empty initialization data
        GenericUUPSProxy proxy = new GenericUUPSProxy(
            implementation,
            ""
        );
        
        emit ProxyDeployed(address(proxy), implementation);
        return address(proxy);
    }
}