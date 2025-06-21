// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/**
 * @title AthenaSkills
 * @dev Library to handle Skill Applications for the NativeAthenaContract
 */
library AthenaSkills {
    struct SkillApplication {
        address applicant;     // Address of the applicant
        string skillName;      // Name of the skill
        string skillOracle;    // Oracle responsible for verification
        string evidenceHash;   // IPFS hash of evidence
        uint256 requestedAt;   // When the verification was requested
        uint256 fee;           // Fee paid for verification
        bool verified;         // Whether the skill is verified
        uint256 votesFor;      // Votes in favor of verification
        uint256 votesAgainst;  // Votes against verification
        uint256 verifiedAt;    // When the skill was verified (if verified)
    }

    struct AppIdMapping {
        bool exists;           // Whether this mapping exists
        address applicant;     // Applicant address
        string skillName;      // Skill name
    }

    /**
     * @dev Initialize a skill application
     * @param application The application to initialize
     * @param applicant Address of the applicant
     * @param skillName Name of the skill
     * @param oracleName Name of the oracle
     * @param evidenceHash IPFS hash of evidence
     * @param fee Fee paid for verification
     */
    function initializeApplication(
        SkillApplication storage application,
        address applicant,
        string memory skillName,
        string memory oracleName,
        string memory evidenceHash,
        uint256 fee
    ) internal {
        application.applicant = applicant;
        application.skillName = skillName;
        application.skillOracle = oracleName;
        application.evidenceHash = evidenceHash;
        application.requestedAt = block.timestamp;
        application.fee = fee;
        application.verified = false;
        application.votesFor = 0;
        application.votesAgainst = 0;
    }

    /**
     * @dev Update application ID mapping
     * @param mapping_ The mapping to update
     * @param applicant Applicant address
     * @param skillName Skill name
     */
    function updateAppIdMapping(
        AppIdMapping storage mapping_,
        address applicant,
        string memory skillName
    ) internal {
        mapping_.exists = true;
        mapping_.applicant = applicant;
        mapping_.skillName = skillName;
    }

    /**
     * @dev Mark a skill as verified
     * @param application The application to verify
     */
    function verifySkill(SkillApplication storage application) internal {
        application.verified = true;
        application.verifiedAt = block.timestamp;
    }
}