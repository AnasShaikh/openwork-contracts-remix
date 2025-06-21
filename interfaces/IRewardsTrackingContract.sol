// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/**
 * @title IRewardsTrackingContract
 * @dev Interface for the RewardsTrackingContract
 */
interface IRewardsTrackingContract {
    /**
     * @dev Record a job completion and calculate rewards
     * @param jobId Unique identifier for the job
     * @param jobValue USD value of the job
     * @param jobPoster Address of the job poster
     */
    function recordJobCompletion(bytes32 jobId, uint256 jobValue, address jobPoster) external;
    
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
     * @dev Get pending rewards for a user
     * @param user Address of the user
     * @return Amount of pending rewards
     */
    function getPendingRewards(address user) external view returns (uint256);
    
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
}