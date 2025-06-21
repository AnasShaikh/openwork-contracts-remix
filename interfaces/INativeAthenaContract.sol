// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IAthenaStorage.sol";

/**
 * @title INativeAthenaContract
 * @dev Interface for the Native Athena Contract
 */
interface INativeAthenaContract {
    // Dispute functions
    function raiseDispute(
        uint256 jobId,
        string calldata disputeHash,
        string calldata oracleName,
        uint256 fee
    ) external payable returns (uint256 disputeId);
    
    function createDispute(uint256 jobId, string memory reason) external payable returns (uint256);
    
    function submitEvidence(uint256 disputeId, string calldata evidenceHash) external returns (bool success);
    
    function voteOnDispute(uint256 disputeId, bool inFavor, string calldata reasonHash) external returns (bool success);
    
    function resolveDispute(uint256 disputeId, address recipient) external returns (bool success);
    
    function escalateDispute(uint256 disputeId) external returns (bool success);
    
    function getDisputeDetails(uint256 disputeId) external view returns (
        IAthenaStorage.Dispute memory dispute,
        uint256 votesFor,
        uint256 votesAgainst
    );
    
    function getDisputeStatus(uint256 disputeId) external view returns (IAthenaStorage.DisputeStatus status);
    
    function getDisputeVotes(uint256 disputeId) external view returns (uint256 votesFor, uint256 votesAgainst);
    
    // Oracle functions
    function createOracle(string calldata name, string calldata description) external returns (bool success);
    
    function addOracleMember(string calldata oracleName, address member) external returns (bool success);
    
    function removeOracleMember(string calldata oracleName, address member) external returns (bool success);
    
    function activateOracle(string calldata oracleName) external returns (bool success);
    
    function deactivateOracle(string calldata oracleName) external returns (bool success);
    
    function isOracleMember(string calldata oracleName, address member) external view returns (bool isMember);
    
    function isActive(string calldata oracleName) external view returns (bool isActive);
    
    function getOracleDetails(string calldata oracleName) external view returns (
        string memory name,
        string memory description,
        address[] memory members,
        bool isActive,
        uint256 createdAt,
        uint256 memberCount
    );
    
    // Skill functions
    function requestSkillVerification(
        string calldata skillName,
        string calldata oracleName,
        string calldata evidenceHash
    ) external payable returns (bool success);
    
    function voteOnSkillVerification(
        address applicant,
        string calldata skillName,
        bool inFavor,
        string calldata reasonHash
    ) external returns (bool success);
    
    function verifySkill(address applicant, string calldata skillName) external returns (bool success);
    
    function isSkillVerified(address applicant, string calldata skillName) external view returns (bool verified);
    
    function getSkillVerificationStatus(address applicant, string calldata skillName) external view returns (
        IAthenaStorage.SkillApplication memory application,
        bool verified
    );
    
    function getSkillApplicationDetails(uint256 applicationId) external view returns (IAthenaStorage.SkillApplication memory application);
    
    // Question functions
    function askAthena(
        string calldata questionHash,
        string calldata oracleName,
        uint256 fee
    ) external payable returns (uint256 questionId);
    
    function voteOnQuestion(
        uint256 questionId,
        bool inFavor,
        string calldata reasonHash
    ) external returns (bool success);
    
    function getQuestionDetails(uint256 questionId) external view returns (
        IAthenaStorage.Question memory question,
        uint256 votesFor,
        uint256 votesAgainst
    );
    
    function getQuestionVotes(uint256 questionId) external view returns (uint256 votesFor, uint256 votesAgainst);
    
    function reportMaliciousMember(
        string calldata oracleName,
        address member,
        string calldata evidenceHash
    ) external returns (bool success);
}