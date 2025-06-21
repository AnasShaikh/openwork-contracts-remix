// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/**
 * @title IAthenaStorage
 * @dev Interface for the Athena Storage contract
 */
interface IAthenaStorage {
    // Dispute status
    enum DisputeStatus { Created, UnderReview, InDeliberation, Resolved, Escalated }
    
    // Dispute structure
    struct Dispute {
        uint256 id;
        uint256 jobId;
        address initiator;
        address respondent;
        string reason;
        DisputeStatus status;
        bool resultDetermined;
        bool fundsReleased;
        address recipient;
        uint256 lockedAmount;
        uint256 createdAt;
        uint256 resolvedAt;
        string evidence;
    }
    
    // Fee structure
    struct FeeStructure {
        uint256 disputeFee;
        uint256 skillVerificationFee;
    }
    
    // Voting periods structure
    struct VotingPeriods {
        uint256 disputeVotingPeriod;
        uint256 skillVotingPeriod;
        uint256 questionVotingPeriod;
    }
    
    // Skill Oracle structure
    struct SkillOracle {
        string name;
        string description;
        address[] members;
        bool isActive;
        uint256 createdAt;
        uint256 memberCount;
    }
    
    // Skill Application structure
    struct SkillApplication {
        address applicant;
        string skillName;
        string skillOracle;
        string evidenceHash;
        uint256 requestedAt;
        uint256 fee;
        bool verified;
        uint256 votesFor;
        uint256 votesAgainst;
        uint256 verifiedAt;
    }
    
    // Application ID Mapping structure
    struct AppIdMapping {
        bool exists;
        address applicant;
        string skillName;
    }
    
    // Question structure
    struct Question {
        uint256 id;
        address asker;
        string questionHash;
        string oracleName;
        uint256 fee;
        uint256 createdAt;
        bool resolved;
        bool result;
        uint256 votesFor;
        uint256 votesAgainst;
    }
    
    // Storage getters
    function getDisputeById(uint256 disputeId) external view returns (Dispute memory);
    function getSkillOracle(string calldata name) external view returns (SkillOracle memory);
    function isOracleMember(string calldata oracleName, address member) external view returns (bool);
    function isSkillVerified(address user, string calldata skillName) external view returns (bool);
    function getSkillApplication(address applicant, string calldata skillName) external view returns (SkillApplication memory);
    function getApplicationIdMapping(uint256 applicationId) external view returns (AppIdMapping memory);
    function getFees() external view returns (FeeStructure memory);
    function getVotingPeriods() external view returns (VotingPeriods memory);
    function getNextDisputeId() external view returns (uint256);
    function getNextQuestionId() external view returns (uint256);
    function getQuestionById(uint256 questionId) external view returns (Question memory);
    function hasVotedOnQuestion(uint256 questionId, address voter) external view returns (bool);
    function getQuestionVoteChoice(uint256 questionId, address voter) external view returns (bool);
    function hasVotedOnDispute(uint256 disputeId, address voter) external view returns (bool);
    function getDisputeVoteChoice(uint256 disputeId, address voter) external view returns (bool);
    function getDisputeVotesFor(uint256 disputeId) external view returns (uint256);
    function getDisputeVotesAgainst(uint256 disputeId) external view returns (uint256);
    function hasVotedOnSkill(address applicant, string calldata skillName, address voter) external view returns (bool);
    function getSkillVoteChoice(address applicant, string calldata skillName, address voter) external view returns (bool);
    
    // Storage setters - these would be called only by authorized contracts
    function setDisputeById(uint256 disputeId, Dispute calldata dispute) external;
    function setSkillOracle(string calldata name, SkillOracle calldata oracle) external;
    function setOracleMembership(string calldata oracleName, address member, bool isMember) external;
    function setSkillVerified(address user, string calldata skillName, bool verified) external;
    function setSkillApplication(address applicant, string calldata skillName, SkillApplication calldata application) external;
    function setApplicationIdMapping(uint256 applicationId, AppIdMapping calldata mapping_) external;
    function setFees(FeeStructure calldata fees) external;
    function setVotingPeriods(VotingPeriods calldata periods) external;
    function setNextDisputeId(uint256 id) external;
    function setNextQuestionId(uint256 id) external;
    function setQuestionById(uint256 questionId, Question calldata question) external;
    function setHasVotedOnQuestion(uint256 questionId, address voter, bool hasVoted) external;
    function setQuestionVoteChoice(uint256 questionId, address voter, bool choice) external;
    function setHasVotedOnDispute(uint256 disputeId, address voter, bool hasVoted) external;
    function setDisputeVoteChoice(uint256 disputeId, address voter, bool choice) external;
    function setDisputeVotesFor(uint256 disputeId, uint256 votes) external;
    function setDisputeVotesAgainst(uint256 disputeId, uint256 votes) external;
    function setHasVotedOnSkill(address applicant, string calldata skillName, address voter, bool hasVoted) external;
    function setSkillVoteChoice(address applicant, string calldata skillName, address voter, bool choice) external;
    
    // Helper functions
    function incrementDisputeId() external returns (uint256);
    function incrementQuestionId() external returns (uint256);
}