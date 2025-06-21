// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/**
 * @title INativeDAOContract
 * @dev Interface for the Native DAO Contract
 */
interface INativeDAOContract {
    /**
     * @dev Register a new skill
     * @param skillName Name of the skill
     * @param ipfsHash IPFS hash of the skill description
     * @param requiredStake Minimum stake required for oracle members
     * @return success True if the skill was successfully registered
     */
    function registerSkill(
        string calldata skillName,
        string calldata ipfsHash,
        uint256 requiredStake
    ) external returns (bool success);
    
    /**
     * @dev Add a member to an oracle
     * @param oracleName Name of the oracle (same as skill name)
     * @param member Address of the member
     * @param stake Amount of tokens staked
     * @return success True if the member was successfully added
     */
    function addOracleMember(
        string calldata oracleName,
        address member,
        uint256 stake
    ) external returns (bool success);
    
    /**
     * @dev Remove a member from an oracle
     * @param oracleName Name of the oracle
     * @param member Address of the member
     * @return success True if the member was successfully removed
     */
    function removeOracleMember(
        string calldata oracleName,
        address member
    ) external returns (bool success);
    
    /**
     * @dev Update a member's stake in an oracle
     * @param oracleName Name of the oracle
     * @param member Address of the member
     * @param newStake New stake amount
     * @return success True if the stake was successfully updated
     */
    function updateOracleMemberStake(
        string calldata oracleName,
        address member,
        uint256 newStake
    ) external returns (bool success);
    
    /**
     * @dev Updates the minimum stake requirement
     * @param newMinimumStake The new minimum stake amount
     * @return success True if the update was successful
     */
    function updateMinimumStake(
        uint256 newMinimumStake
    ) external returns (bool success);
    
    /**
     * @dev Updates the required votes for proposal passage
     * @param newRequiredVotes The new required vote threshold
     * @return success True if the update was successful
     */
    function updateRequiredVotes(
        uint256 newRequiredVotes
    ) external returns (bool success);
    
    /**
     * @dev Gets the stake of an oracle member
     * @param oracleName Name of the oracle
     * @param member Address of the member
     * @return stake The stake amount
     */
    function getOracleMemberStake(string memory oracleName, address member) external view returns (uint256 stake);
    
    /**
     * @dev Checks if a skill is registered
     * @param skillName Name of the skill
     * @return registered True if the skill is registered
     */
    function isSkillRegistered(string memory skillName) external view returns (bool registered);
    
    /**
     * @dev Gets the oracle name for a skill
     * @param skillName Name of the skill
     * @return oracleName The oracle name
     */
    function getSkillOracleName(string memory skillName) external view returns (string memory oracleName);
    
    /**
     * @dev Checks if a user has a verified skill
     * @param user Address of the user
     * @param skillName Name of the skill
     * @return hasSkill True if the user has the skill
     */
    function hasUserSkill(address user, string memory skillName) external view returns (bool hasSkill);
}
