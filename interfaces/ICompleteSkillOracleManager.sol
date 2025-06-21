// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/**
 * @title ICompleteSkillOracleManager
 * @dev Complete interface for the Skill Oracle Manager contract
 */
interface ICompleteSkillOracleManager {
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
     * @return success True if the update was successful
     */
    function updateMinimumMembers(uint8 newMinimumMembers) external returns (bool success);
    
    /**
     * @dev Set the governance contract address
     * @param governanceAddress Address of the governance contract
     */
    function setGovernanceContract(address governanceAddress) external;
    
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
     * @dev Verifies a user's skill
     * @param user Address of the user
     * @param skillName Name of the skill
     */
    function verifyUserSkill(address user, string calldata skillName) external;
    
    /**
     * @dev Add skills in bulk
     * @param skillNames Array of skill names
     * @param ipfsHashes Array of IPFS hashes
     * @return success True if the skills were successfully added
     */
    function addSkills(
        string[] calldata skillNames,
        string[] calldata ipfsHashes
    ) external returns (bool success);
    
    /**
     * @dev Remove skills in bulk
     * @param skillNames Array of skill names
     * @return success True if the skills were successfully removed
     */
    function removeSkills(
        string[] calldata skillNames
    ) external returns (bool success);
    
    /**
     * @dev Add an oracle for a skill
     * @param skillName Name of the skill
     * @return success True if the oracle was successfully added
     */
    function addOracle(string calldata skillName) external returns (bool success);
    
    /**
     * @dev Add a member to a skill oracle
     * @param oracleName Name of the oracle
     * @param members Array of member addresses
     * @param stakes Array of stake amounts
     * @return success True if the members were successfully added
     */
    function addMemberToSkillOracle(
        string calldata oracleName,
        address[] calldata members,
        uint256[] calldata stakes
    ) external returns (bool success);
    
    /**
     * @dev Remove members from an oracle
     * @param oracleName Name of the oracle
     * @param members Array of member addresses
     * @return success True if the members were successfully removed
     */
    function removeMembers(
        string calldata oracleName,
        address[] calldata members
    ) external returns (bool success);
    
    /**
     * @dev Set an oracle as active
     * @param oracleName Name of the oracle
     * @param isActive Whether the oracle should be active
     * @return success True if the oracle was successfully updated
     */
    function setOracleActive(
        string calldata oracleName,
        bool isActive
    ) external returns (bool success);
    
    /**
     * @dev Remove stake from a member as a penalty
     * @param oracleName Name of the oracle
     * @param member Address of the member
     * @param amount Amount to remove
     * @return success True if the stake was successfully removed
     */
    function removeStake(
        string calldata oracleName,
        address member,
        uint256 amount
    ) external returns (bool success);
    
    /**
     * @dev Checks if a user is an oracle member
     * @param oracleName Name of the oracle
     * @param member Address of the member
     * @return exists True if the member exists
     */
    function isOracleMember(string memory oracleName, address member) external view returns (bool exists);
    
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
    
    /**
     * @dev Gets the total staked amount in an oracle
     * @param oracleName Name of the oracle
     * @return amount The total staked amount
     */
    function getOracleTotalStaked(string memory oracleName) external view returns (uint256 amount);
    
    /**
     * @dev Gets the member count of an oracle
     * @param oracleName Name of the oracle
     * @return count The member count
     */
    function getOracleMemberCount(string memory oracleName) external view returns (uint256 count);
    
    /**
     * @dev Checks if an oracle is active
     * @param oracleName Name of the oracle
     * @return active True if the oracle is active
     */
    function isOracleActive(string memory oracleName) external view returns (bool active);
    
    /**
     * @dev Gets the IPFS hash of a skill
     * @param skillName Name of the skill
     * @return ipfsHash The IPFS hash
     */
    function getSkillIpfsHash(string memory skillName) external view returns (string memory ipfsHash);
    
    /**
     * @dev Gets the verification date of a user's skill
     * @param user Address of the user
     * @param skillName Name of the skill
     * @return verificationDate The verification date
     */
    function getUserSkillVerificationDate(address user, string memory skillName) external view returns (uint256 verificationDate);
    
    /**
     * @dev Gets all active members of an oracle
     * @param oracleName Name of the oracle
     * @return members Array of active member addresses
     */
    function getOracleMembers(string memory oracleName) external view returns (address[] memory members);
    
    /**
     * @dev Validates if an oracle meets dispute resolution requirements
     * @param oracleName Name of the oracle
     * @return isValid True if oracle can handle disputes
     */
    function validateOracleForDisputes(string memory oracleName) external view returns (bool isValid);
    
    /**
     * @dev Gets oracle member's voting weight for disputes
     * @param oracleName Name of the oracle
     * @param member Address of the member
     * @return weight Voting weight based on stake
     */
    function getOracleMemberVotingWeight(string memory oracleName, address member) external view returns (uint256 weight);
}