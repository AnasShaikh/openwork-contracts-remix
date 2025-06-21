// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title SkillQuestionStorage
 * @dev Storage structures for skill verification and question/answer system
 */
library SkillStorage {
    enum SkillStatus { Applied, Pending, Verified, Rejected }
    
    struct SkillApplication {
        uint256 id;
        address applicant;
        string skillName;
        string evidence;
        string oracleName;
        SkillStatus status;
        uint256 createdAt;
        uint256 verifiedAt;
    }
}

library QuestionStorage {
    enum QuestionStatus { Asked, Answered, Expired }
    
    struct Question {
        uint256 id;
        address asker;
        string questionHash;
        string oracleName;
        QuestionStatus status;
        uint256 createdAt;
        uint256 answeredAt;
    }
}