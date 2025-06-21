// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/**
 * @title ICompleteNativeDAOGovernance
 * @dev Complete interface for the Native DAO Governance contract
 */
interface ICompleteNativeDAOGovernance {
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
     * @dev Record governance action for a user
     * @param user Address of the user
     * @param actionWeight Weight of the governance action
     */
    function recordGovernanceAction(address user, uint256 actionWeight) external;
    
    /**
     * @dev Get the required action threshold for a governance level
     * @param level Governance level
     * @return Required action threshold
     */
    function getRequiredActionThreshold(uint256 level) external view returns (uint256);
    
    /**
     * @dev Send skill verification information to governance contract
     * @param user Address of the user
     * @param skillName Name of the skill
     * @param verificationDate Date of verification
     */
    function sendSkillVerification(address user, string calldata skillName, uint256 verificationDate) external;
}