// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../libraries/DisputeOracleStorage.sol";

/**
 * @title IOracleEngine
 * @dev Interface for oracle management functionality
 */
interface IOracleEngine {
    // Oracle functions
    function createOracle(string calldata name, string calldata description) external returns (bool success);
    
    function addOracleMember(string calldata oracleName, address member) external returns (bool success);
    
    function removeOracleMember(string calldata oracleName, address member) external returns (bool success);
    
    function activateOracle(string calldata oracleName) external returns (bool success);
    
    function deactivateOracle(string calldata oracleName) external returns (bool success);
    
    function isOracleMember(string calldata oracleName, address member) external view returns (bool isMember);
    
    function isActive(string calldata oracleName) external view returns (bool);
    
    function getOracleDetails(string calldata oracleName) external view returns (
        string memory name,
        string memory description,
        address[] memory members,
        bool active,
        uint256 createdAt,
        uint256 memberCount
    );
    
    function reportMaliciousMember(
        string calldata oracleName,
        address member,
        string calldata evidenceHash
    ) external returns (bool success);
    
    function isReportedInOracle(string calldata oracleName, address member) external view returns (bool reported);
}