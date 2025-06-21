/**
 * @title IUnifiedRewardsTracking TypeScript Interface
 * @dev TypeScript definitions for IUnifiedRewardsTracking Solidity interface
 * @notice Comprehensive rewards tracking interface that consolidates previous interfaces
 */
export interface IUnifiedRewardsTracking {
  // Core job and earnings tracking
  recordJobCompletion(jobId: string, jobValue: number, recipient: string): Promise<number>;
  recordEarnings(user: string, amount: number): Promise<void>;
  
  // Rewards management
  getPendingRewards(user: string): Promise<number>;
  getClaimedRewards(user: string): Promise<number>;
  calculateTokenReward(jobValue: number): Promise<number>;
  claimRewards(): Promise<void>;
  
  // Governance functionality
  recordGovernanceAction(user: string, actionWeight: number): Promise<void>;
  hasCompletedGovernanceActions(user: string, level: number): Promise<boolean>;
  
  // Staking functionality
  stakeTokens(amount: number, duration: number): Promise<void>;
  unstakeTokens(stakeIndex: number): Promise<void>;
  getTotalStakedTokens(user: string): Promise<number>;
  
  // Allowlist management
  addToClaimAllowlist(user: string, amount: number): Promise<boolean>;
}