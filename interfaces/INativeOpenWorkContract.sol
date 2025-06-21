// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/**
 * @title INativeOpenWorkContract
 * @dev Interface for the Native OpenWork Contract
 */
interface INativeOpenWorkContract {
    /**
     * @dev Record a job completion 
     * @param jobId Unique identifier for the job
     * @param jobValue USD value of the job
     * @param jobPoster Address of the job poster
     * @return success Indicates if the job completion was successfully recorded
     */
    function recordJobCompletion(bytes32 jobId, uint256 jobValue, address jobPoster) external returns (bool success);
    
    /**
     * @dev Check if a job exists
     * @param jobId Unique identifier for the job
     * @return Whether the job exists
     */
    function jobExists(uint256 jobId) external view returns (bool);
    
    /**
     * @dev Get job details
     * @param jobId Unique identifier for the job
     * @return jobPoster Address of the job poster
     * @return jobValue USD value of the job
     * @return isComplete Whether the job is complete
     */
    function getJobDetails(uint256 jobId) external view returns (address jobPoster, uint256 jobValue, bool isComplete);
    
    /**
     * @dev Get detailed job posting information
     * @param jobId ID of the job
     * @return id The job ID
     * @return client The client's address
     * @return title The job title
     * @return description The job description
     * @return budget The job budget
     * @return deadline The job deadline timestamp
     * @return createdAt The job creation timestamp
     * @return freelancer The freelancer's address
     * @return isCompleted Whether the job is completed
     * @return paymentAmount The payment amount for the job
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
        bool isCompleted,
        uint256 paymentAmount
    );
    
    /**
     * @dev Lock funds for a disputed job
     * @param jobId ID of the job
     * @param disputeId ID of the dispute
     * @return amount Amount of funds locked
     */
    function lockDisputedFunds(uint256 jobId, uint256 disputeId) external returns (uint256 amount);
    
    /**
     * @dev Release funds locked in a dispute
     * @param jobId ID of the job
     * @param disputeId ID of the dispute
     * @param winnerAddress Address of the winning party (converted to uint256)
     * @param loserAddress Address of the losing party (converted to uint256)
     * @param amount Amount to release
     * @param feeAmount Fee amount to be deducted
     * @return success Whether the operation was successful
     */
    function releaseDisputedFunds(
        uint256 jobId,
        uint256 disputeId,
        uint256 winnerAddress,
        uint256 loserAddress,
        uint256 amount,
        uint256 feeAmount
    ) external returns (bool success);
}