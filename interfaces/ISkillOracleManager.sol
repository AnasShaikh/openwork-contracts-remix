// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/**
 * @title ISkillOracleManager
 * @dev Interface for the Skill Oracle Manager contract
 */
interface ISkillOracleManager {
    /**
     * @dev Record a verification action performed by a verifier
     * @param verifier Address of the verifier
     * @param actionWeight Weight of the verification action
     */
    function recordVerifierAction(address verifier, uint256 actionWeight) external;
    
    /**
     * @dev Check if a user is an active verifier
     * @param user Address of the user
     * @return Whether the user is an active verifier
     */
    function isActiveVerifier(address user) external view returns (bool);
    
    /**
     * @dev Get the verifier level of a user
     * @param user Address of the user
     * @return Verifier level (0-3, or max uint256 if not a verifier)
     */
    function getVerifierLevel(address user) external view returns (uint256);
    
    /**
     * @dev Update minimum members required for an oracle
     * @param newMinimumMembers New minimum members value
     */
    function updateMinimumMembers(uint8 newMinimumMembers) external;
}