// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/**
 * @title ILocalOpenWorkContract
 * @dev Interface for the Local OpenWork Contract on various chains
 * This contract would handle user interactions on different blockchains
 */
interface ILocalOpenWorkContract {
    /**
     * @dev Upgrades the Local OpenWork Contract implementation
     * @param newImplementation The address of the new implementation contract
     */
    function upgradeToAndCall(address newImplementation, bytes calldata data) external;
    
    /**
     * @dev Create a user profile - sends a message to the Native OpenWork contract
     * @param name The name of the user
     * @param skills Array of user skills
     * @param profileHash IPFS hash containing extended profile data
     */
    function createUserProfile(
        string memory name,
        string[] memory skills,
        string memory profileHash
    ) external payable;
    
    /**
     * @dev Update a user profile - sends a message to the Native OpenWork contract
     * @param name The updated name of the user
     * @param skills Updated array of user skills
     * @param profileHash Updated IPFS hash containing extended profile data
     */
    function updateUserProfile(
        string memory name,
        string[] memory skills,
        string memory profileHash
    ) external payable;
}
