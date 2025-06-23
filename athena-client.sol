// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SkillVerificationDispute {
    
    struct Oracle {
        string name;
        address[] members;
        string shortDescription;
        string hashOfDetails;
        uint256 stakeAmount;
        address[] skillVerifiedAddresses;
    }
    
    struct SkillVerificationApplication {
        address applicant;
        string applicationHash;
        uint256 feeAmount;
        string targetOracleName;
    }
    
    struct Dispute {
        uint256 jobID;
        uint256 disputedAmount;
        string hash;
        address disputeRaiserAddress;
        uint256 votesFor;
        uint256 votesAgainst;
        bool result;
        bool isVotingActive;
        uint256 timeStamp;
        uint256 fees;
    }
    
    mapping(string => Oracle) public oracles;
    mapping(uint256 => SkillVerificationApplication) public skillApplications;
    mapping(uint256 => Dispute) public disputes;
    uint256 public applicationCounter;
    uint256 public disputeCounter;
    uint256 public minOracleMembers = 3;
    
    constructor() {
        // Initialize counters
        applicationCounter = 0;
        disputeCounter = 0;
    }
    
    function submitSkillVerification(
        string memory _applicationHash,
        uint256 _feeAmount,
        string memory _targetOracleName
    ) external {
        skillApplications[applicationCounter] = SkillVerificationApplication({
            applicant: msg.sender,
            applicationHash: _applicationHash,
            feeAmount: _feeAmount,
            targetOracleName: _targetOracleName
        });
        applicationCounter++;
    }
    
    function raiseDispute(
        uint256 _jobId,
        string memory _disputeHash,
        string memory _oracleName,
        uint256 _fee
    ) external {
        // Check if oracle is active (has minimum required members)
        require(oracles[_oracleName].members.length >= minOracleMembers, "Oracle not active");
        
        // TODO: Implement getJobDetails() - get job details from another contract
        
        // TODO: Implement check if caller is involved in the job
        
        // Create new dispute
        disputes[disputeCounter] = Dispute({
            jobID: _jobId,
            disputedAmount: _fee,
            hash: _disputeHash,
            disputeRaiserAddress: msg.sender,
            votesFor: 0,
            votesAgainst: 0,
            result: false,
            isVotingActive: true,
            timeStamp: block.timestamp,
            fees: _fee
        });
        disputeCounter++;
    }
    
    // Getter functions for accessing stored data
    function getSkillApplication(uint256 _applicationId) external view returns (
        address applicant,
        string memory applicationHash,
        uint256 feeAmount,
        string memory targetOracleName
    ) {
        require(_applicationId < applicationCounter, "Invalid application ID");
        SkillVerificationApplication memory app = skillApplications[_applicationId];
        return (app.applicant, app.applicationHash, app.feeAmount, app.targetOracleName);
    }
    
    function getDispute(uint256 _disputeId) external view returns (
        uint256 jobID,
        uint256 disputedAmount,
        string memory hash,
        address disputeRaiserAddress,
        uint256 votesFor,
        uint256 votesAgainst,
        bool result,
        bool isVotingActive,
        uint256 timeStamp,
        uint256 fees
    ) {
        require(_disputeId < disputeCounter, "Invalid dispute ID");
        Dispute memory dispute = disputes[_disputeId];
        return (
            dispute.jobID,
            dispute.disputedAmount,
            dispute.hash,
            dispute.disputeRaiserAddress,
            dispute.votesFor,
            dispute.votesAgainst,
            dispute.result,
            dispute.isVotingActive,
            dispute.timeStamp,
            dispute.fees
        );
    }
    
    function getApplicationCounter() external view returns (uint256) {
        return applicationCounter;
    }
    
    function getDisputeCounter() external view returns (uint256) {
        return disputeCounter;
    }
}