// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/**
 * @title IGovernanceActionTracker
 * @dev Interface for the Governance Action Tracker contract
 * This contract tracks governance actions across multiple contracts and chains
 */
interface IGovernanceActionTracker {
    /**
     * @dev Record a governance action for a user
     * @param user Address of the user
     */
    function recordGovernanceAction(address user) external;
    
    /**
     * @dev Record a governance action with a specific weight for a user
     * @param user Address of the user
     * @param actionWeight Weight of the governance action
     */
    function recordGovernanceActionWithWeight(address user, uint256 actionWeight) external;
    
    /**
     * @dev Add a contract to the authorized list
     * @param contractAddress Address of the contract to authorize
     */
    function addAuthorizedContract(address contractAddress) external;
    
    /**
     * @dev Remove a contract from the authorized list
     * @param contractAddress Address of the contract to remove
     */
    function removeAuthorizedContract(address contractAddress) external;
    
    /**
     * @dev Get the required action threshold for a governance level
     * @param level Governance level
     * @return Required action threshold
     */
    function getRequiredActionThreshold(uint256 level) external view returns (uint256);
    
    /**
     * @dev Get the total number of governance actions performed by a user
     * @param user Address of the user
     * @return The total number of governance actions
     */
    function getTotalGovernanceActions(address user) external view returns (uint256);
    
    /**
     * @dev Set the Layer Zero bridge
     * @param _layerZeroBridge Address of the Layer Zero bridge for cross-chain communication
     */
    function setLayerZeroBridge(address _layerZeroBridge) external;
    
    /**
     * @dev Update the required action thresholds for different levels
     * @param level Level to update
     * @param threshold New threshold value
     */
    function updateRequiredActionThreshold(uint256 level, uint256 threshold) external;
    
    /**
     * @dev Check if a user has completed sufficient governance actions for a level
     * @param user Address of the user
     * @param level Governance level
     * @return Whether user has completed the required actions
     */
    function hasCompletedGovernanceActions(address user, uint256 level) external view returns (bool);
}