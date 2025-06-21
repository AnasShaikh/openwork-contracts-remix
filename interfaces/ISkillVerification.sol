// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../libraries/SkillQuestionStorage.sol";

/**
 * @title ISkillVerification
 * @dev Interface for skill verification functionality
 */
interface ISkillVerification {
    // Skill functions
    function requestSkillVerification(
        string calldata skillName,
        string calldata oracleName,
        string calldata evidenceHash
    ) external payable returns (bool success);
    
    function applyForSkillVerification(
        string calldata skillName,
        string calldata oracleName,
        string calldata evidenceHash
    ) external payable returns (uint256 applicationId);
    
    function voteOnSkillVerification(
        address applicant,
        string calldata skillName,
        bool inFavor,
        string calldata reasonHash
    ) external returns (bool success);
    
    function voteOnSkillApplication(
        uint256 applicationId,
        bool inFavor,
        string calldata reasonHash
    ) external returns (bool success);
    
    function verifySkill(address applicant, string calldata skillName) external returns (bool success);
    
    function isSkillVerified(address applicant, string calldata skillName) external view returns (bool verified);
    
    function getSkillVerificationStatus(address applicant, string calldata skillName) external view returns (
        SkillStorage.SkillApplication memory application,
        bool verified
    );
    
    function getSkillApplicationDetails(uint256 applicationId) external view returns (
        SkillStorage.SkillApplication memory application
    );
    
    function claimSkillVerificationFeeReward(
        address applicant,
        string calldata skillName
    ) external returns (uint256 amount);
    
    function claimSkillVerificationFeeRefund(
        string calldata skillName
    ) external returns (uint256 amount);
}