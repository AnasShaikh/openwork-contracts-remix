// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/**
 * @title INativeDAOGovernance
 * @dev Interface for the Native DAO Governance contract
 */
interface INativeDAOGovernance {
    /**
     * @dev Check if a user has voting rights
     * @param user Address of the user
     * @return Whether the user has voting rights
     */
    function hasVotingRights(address user) external view returns (bool);
    
    /**
     * @dev Get the voting power of a user
     * @param user Address of the user
     * @return Voting power amount
     */
    function getVotingPower(address user) external view returns (uint256);
    
    /**
     * @dev Record a governance action for a user
     * This function delegates to the GovernanceActionTracker contract
     * @param user Address of the user
     */
    function recordGovernanceAction(address user) external;
    
    /**
     * @dev Add a contract to the authorized list in the GovernanceActionTracker
     * @param contractAddress Address of the contract to authorize
     */
    function addAuthorizedContract(address contractAddress) external;
    
    /**
     * @dev Remove a contract from the authorized list in the GovernanceActionTracker
     * @param contractAddress Address of the contract to remove
     */
    function removeAuthorizedContract(address contractAddress) external;
    
    /**
     * @dev Get the required action threshold for a governance level from the GovernanceActionTracker
     * @param level Governance level
     * @return Required action threshold
     */
    function getRequiredActionThreshold(uint256 level) external view returns (uint256);
    
    /**
     * @dev Get the total number of governance actions performed by a user from the GovernanceActionTracker
     * @param user Address of the user
     * @return The total number of governance actions
     */
    function getTotalGovernanceActions(address user) external view returns (uint256);
    
    /**
     * @dev Set the governance action tracker contract address
     * @param _governanceActionTracker Address of the governance action tracker contract
     */
    function setGovernanceActionTracker(address _governanceActionTracker) external;
}