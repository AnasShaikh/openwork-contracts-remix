// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title DisputeOracleStorage
 * @dev Storage structures for dispute resolution and oracle management
 */
library DisputeStorage {
    enum DisputeStatus { Created, UnderReview, InDeliberation, Resolved, Escalated }
    
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
        string assignedOracle;      // Oracle handling this dispute
        uint256 requiredVotes;      // Minimum votes needed from oracle
        bool oracleValidated;       // Oracle meets requirements
    }
}

library OracleStorage {
    struct SkillOracle {
        string name;
        string description;
        address[] members;
        bool isActive;
        uint256 createdAt;
        uint256 memberCount;
    }
}