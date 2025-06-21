// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title IOpenWorkJobMarket
 * @dev Interface for the OpenWork Job Market Contract
 */
interface IOpenWorkJobMarket {
    /**
     * @dev ProposedMilestones struct for standardizing milestone proposal data
     */
    struct ProposedMilestones {
        bool hasMilestoneProposal;
        uint256[] milestonePayments;
        string milestoneDetailsHash; // IPFS hash containing milestone descriptions
    }

    /**
     * @dev Check if a job exists
     * @param jobId ID of the job
     * @return exists True if the job exists
     */
    function jobExists(uint256 jobId) external view returns (bool exists);

    /**
     * @dev Post a new job
     * @param ipfsHash IPFS hash containing job details
     * @param milestones Array of milestone payment amounts
     * @return jobId The ID of the created job
     */
    function postJob(
        string memory ipfsHash,
        uint256[] memory milestones
    ) external returns (uint256 jobId);

    /**
     * @dev Apply for a job with optional proposed milestones
     * @param jobId The ID of the job
     * @param application_hash IPFS hash containing the application details
     * @param proposedMilestones Array of proposed milestone payment amounts (optional)
     * @param milestoneDetailsHash IPFS hash containing milestone descriptions (optional)
     */
    function applyToJobWithProposal(
        uint256 jobId,
        string memory application_hash,
        uint256[] memory proposedMilestones,
        string memory milestoneDetailsHash
    ) external;

    /**
     * @dev Apply for a job (simplified version)
     * @param jobId The ID of the job
     * @param application_hash IPFS hash containing the application details
     */
    function applyToJob(uint256 jobId, string memory application_hash) external;

    /**
     * @dev Start a job and accept milestone proposal
     * @param jobId The ID of the job
     * @param applicant The address of the selected applicant
     * @param acceptProposedMilestones Whether to accept the applicant's proposed milestones
     */
    function startJobWithProposedMilestones(
        uint256 jobId,
        address applicant,
        bool acceptProposedMilestones
    ) external payable;

    /**
     * @dev Start a job and lock the first milestone payment
     * @param jobId The ID of the job
     * @param applicant The address of the selected applicant
     */
    function startJob_LockMilestone1(uint256 jobId, address applicant) external payable;

    /**
     * @dev Get job posting details
     * @param jobId ID of the job
     * @return id Job ID
     * @return client Client address
     * @return title Job title
     * @return description Job description
     * @return budget Total budget
     * @return deadline Job deadline
     * @return createdAt Creation timestamp
     * @return freelancer Selected freelancer address
     * @return status Job status
     * @return completedAt Completion timestamp
     */
    function getJobPosting(uint256 jobId) external view returns (
        uint256 id,
        address client,
        string memory title,
        string memory description,
        uint256 budget,
        uint256 deadline,
        uint256 createdAt,
        address freelancer,
        uint256 status,
        uint256 completedAt
    );

    /**
     * @dev Get detailed job information
     * @param jobId ID of the job
     * @return id Job ID
     * @return jobGiver Job giver address
     * @return jobDetailHash IPFS hash containing job details
     * @return isOpen Whether the job is open for applications
     * @return isCompleted Whether the job is completed
     * @return selectedApplicant The address of the selected freelancer
     * @return currentMilestone Current milestone index
     * @return totalMilestones Total number of milestones
     * @return totalPaid Total amount paid so far
     * @return applicantCount Number of applicants
     */
    function getJobDetails(uint256 jobId) external view returns (
        uint256 id,
        address jobGiver,
        string memory jobDetailHash,
        bool isOpen,
        bool isCompleted,
        address selectedApplicant,
        uint256 currentMilestone,
        uint256 totalMilestones,
        uint256 totalPaid,
        uint256 applicantCount
    );

    /**
     * @dev Submit work for a job
     * @param jobId ID of the job
     * @param workHash IPFS hash containing the submitted work
     * @param comments Additional comments for the submission
     * @return submissionId The ID of the created submission
     */
    function submitWork(
        uint256 jobId,
        string memory workHash,
        string memory comments
    ) external returns (uint256 submissionId);

    /**
     * @dev Approve submitted work
     * @param submissionId ID of the submission
     */
    function approveWork(uint256 submissionId) external;

    /**
     * @dev Reject submitted work
     * @param submissionId ID of the submission
     * @param feedback Feedback explaining the rejection
     */
    function rejectWork(uint256 submissionId, string memory feedback) external;

    /**
     * @dev Cancel a job
     * @param jobId ID of the job
     * @return success True if the job was cancelled
     */
    function cancelJob(uint256 jobId) external returns (bool success);

    /**
     * @dev Check if an applicant has proposed milestones
     * @param jobId ID of the job
     * @param applicant Address of the applicant
     * @return hasProposal True if the applicant has proposed milestones
     */
    function hasProposedMilestones(uint256 jobId, address applicant) external view returns (bool hasProposal);

    /**
     * @dev Get proposed milestones from an applicant
     * @param jobId ID of the job
     * @param applicant Address of the applicant
     * @return hasMilestoneProposal Whether the applicant has proposed milestones
     * @return milestonePayments Array of proposed milestone payment amounts
     * @return milestoneDetailsHash IPFS hash containing milestone descriptions
     */
    function getProposedMilestones(uint256 jobId, address applicant) external view returns (
        bool hasMilestoneProposal,
        uint256[] memory milestonePayments,
        string memory milestoneDetailsHash
    );

    /**
     * @dev Lock funds for a disputed job
     * @param jobId ID of the job
     * @param disputeId ID of the dispute
     * @return lockedAmount Amount of funds locked
     */
    function lockDisputedFunds(uint256 jobId, uint256 disputeId) external returns (uint256 lockedAmount);

    /**
     * @dev Release disputed funds
     * @param jobId ID of the job
     * @param disputeId ID of the dispute
     * @param winner Address of the winner (as uint256)
     * @param loser Address of the loser (as uint256)
     * @param amount Amount to release
     * @param platformFee Platform fee to deduct
     * @return success True if the funds were released
     */
    function releaseDisputedFunds(
        uint256 jobId,
        uint256 disputeId,
        uint256 winner,
        uint256 loser,
        uint256 amount,
        uint256 platformFee
    ) external returns (bool success);

    /**
     * @dev Complete a milestone and unlock the next one
     * @param jobId ID of the job
     * @param milestoneIndex Index of the milestone to complete
     */
    function completeMilestone_UnlockNext(uint256 jobId, uint256 milestoneIndex) external;

    /**
     * @dev Start the next milestone and lock the payment
     * @param jobId ID of the job
     */
    function startNextMilestone(uint256 jobId) external payable;

    /**
     * @dev Get the total milestone amount for a job
     * @param jobId ID of the job
     * @return totalAmount Total amount across all milestones
     */
    function getTotalMilestoneAmount(uint256 jobId) external view returns (uint256 totalAmount);

    /**
     * @dev Get the number of milestones for a job
     * @param jobId ID of the job
     * @return count Number of milestones
     */
    function getMilestoneCount(uint256 jobId) external view returns (uint256 count);

    /**
     * @dev Get milestone details
     * @param jobId ID of the job
     * @param milestoneIndex Index of the milestone
     * @return amount Payment amount for the milestone
     * @return completed Whether the milestone is completed
     * @return paid Whether the milestone payment has been paid
     */
    function getMilestone(uint256 jobId, uint256 milestoneIndex) external view returns (
        uint256 amount,
        bool completed,
        bool paid
    );

    /**
     * @dev Get the number of applicants for a job
     * @param jobId ID of the job
     * @return count Number of applicants
     */
    function getApplicantCount(uint256 jobId) external view returns (uint256 count);

    /**
     * @dev Get an applicant address for a job
     * @param jobId ID of the job
     * @param applicantIndex Index of the applicant
     * @return applicant Address of the applicant
     */
    function getApplicant(uint256 jobId, uint256 applicantIndex) external view returns (address applicant);

    /**
     * @dev Get application details for a job
     * @param jobId ID of the job
     * @param applicantIndex Index of the applicant
     * @return applicant Address of the applicant
     * @return proposalHash IPFS hash containing the proposal
     */
    function getApplication(uint256 jobId, uint256 applicantIndex) external view returns (
        address applicant,
        string memory proposalHash
    );

    /**
     * @dev Complete a job
     * @param jobId ID of the job
     */
    function completeJob(uint256 jobId) external;

    /**
     * @dev Create a dispute for a job
     * @param jobId ID of the job
     * @param reason Reason for the dispute
     */
    function createDispute(uint256 jobId, string memory reason) external;

    /**
     * @dev Resolve a dispute
     * @param jobId ID of the job
     * @param favorFreelancer Whether the dispute was resolved in favor of the freelancer
     * @param freelancerShare Percentage of funds to be given to the freelancer (0-100)
     */
    function resolveDispute(uint256 jobId, bool favorFreelancer, uint8 freelancerShare) external;

    /**
     * @dev Fund a job
     * @param jobId ID of the job
     */
    function fundJob(uint256 jobId) external payable;

    /**
     * @dev Set the user registry contract address
     * @param userRegistryAddress The address of the user registry contract
     */
    function setUserRegistryContract(address userRegistryAddress) external;

    /**
     * @dev Set the earnings rewards contract address
     * @param earningsContractAddress The address of the earnings contract
     */
    function setEarningsContract(address earningsContractAddress) external;

    // Cross-chain specific functions
    
    /**
     * @dev Start a job for an interchain application
     * @param jobId ID of the job
     * @param applicant Address of the selected applicant
     * @param acceptProposedMilestones Whether to accept the applicant's proposed milestones
     */
    function startJobInterChain(uint256 jobId, address applicant, bool acceptProposedMilestones) external;
    
    /**
     * @dev Release payment for a milestone on interchain job
     * @param jobId ID of the job
     * @param milestoneIndex Index of the milestone
     * @param amountReleased The amount that was released on the local chain
     */
    function releasePaymentInterchain(uint256 jobId, uint256 milestoneIndex, uint256 amountReleased) external;
    
    /**
     * @dev Lock next milestone payment for interchain job
     * @param jobId ID of the job
     * @param milestoneAmount The amount locked on the local chain
     */
    function lockNextMilestoneInterchain(uint256 jobId, uint256 milestoneAmount) external;
}