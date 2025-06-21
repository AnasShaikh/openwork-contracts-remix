// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/**
 * @title IUnifiedRewardsTracking
 * @dev Interface for unified rewards tracking across different implementations
 *      Combines functionality from legacy IEarningsRewardsContract and IRewardsTrackingContract
 *      to provide a single comprehensive interface
 */
interface IUnifiedRewardsTracking {
    // Events for tracking rewards activities
    event UnifiedJobCompleted(bytes32 indexed jobId, address indexed jobPoster, uint256 jobValue);
    event UnifiedRewardsEarned(address indexed user, uint256 amount);
    event UnifiedRewardsClaimed(address indexed user, uint256 amount);
    event GovernanceActionRecorded(address indexed user, uint256 actionWeight);

    /**
     * @dev Records a job completion and calculates rewards
     * @param jobId Unique identifier for the job
     * @param jobValue The value of the job in USD (6 decimals)
     * @param recipient Address that will receive the rewards (job poster)
     * @return rewardsAmount The amount of rewards calculated for this job
     */
    function recordJobCompletion(
        bytes32 jobId, 
        uint256 jobValue, 
        address recipient
    ) external returns (uint256 rewardsAmount);
    
    /**
     * @dev Record earnings for a user - from IEarningsRewardsContract
     * @param user Address of the user
     * @param amount Amount of earnings to record
     */
    function recordEarnings(address user, uint256 amount) external;
    
    /**
     * @dev Returns the amount of pending rewards for a user
     * @param user The address to check
     * @return The amount of pending rewards
     */
    function getPendingRewards(address user) external view returns (uint256);
    
    /**
     * @dev Returns the amount of claimed rewards for a user
     * @param user The address to check
     * @return The amount of claimed rewards
     */
    function getClaimedRewards(address user) external view returns (uint256);
    
    /**
     * @dev Calculate token reward based on job value and current band rate
     * @param jobValue USD value of the job
     * @return Amount of tokens to be rewarded
     */
    function calculateTokenReward(uint256 jobValue) external view returns (uint256);
    
    /**
     * @dev Claim pending token rewards
     */
    function claimRewards() external;
    
    /**
     * @dev Record a governance action performed by a user
     * @param user Address of the user
     * @param actionWeight Weight of the governance action
     */
    function recordGovernanceAction(address user, uint256 actionWeight) external;
    
    /**
     * @dev Check if a user has completed sufficient governance actions for a level
     * @param user Address of the user
     * @param level Governance level
     * @return Whether user has completed the required actions
     */
    function hasCompletedGovernanceActions(address user, uint256 level) external view returns (bool);
    
    /**
     * @dev Stake tokens for governance participation
     * @param amount Amount of tokens to stake
     * @param duration Duration of staking in days
     */
    function stakeTokens(uint256 amount, uint256 duration) external;
    
    /**
     * @dev Unstake tokens after staking period
     * @param stakeIndex Index of the stake in the user's staking array
     */
    function unstakeTokens(uint256 stakeIndex) external;
    
    /**
     * @dev Get the total amount of tokens staked by a user
     * @param user Address of the user
     * @return Total staked tokens
     */
    function getTotalStakedTokens(address user) external view returns (uint256);
    
    /**
     * @dev Adds a user to the claim allowlist with a specific amount
     * @param user The address to add to the allowlist
     * @param amount The amount to allow
     * @return success Whether the operation was successful
     */
    function addToClaimAllowlist(address user, uint256 amount) external returns (bool);
}