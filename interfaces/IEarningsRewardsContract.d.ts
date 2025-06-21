/**
 * @title IEarningsRewardsContract TypeScript Interface
 * @dev TypeScript definitions for IEarningsRewardsContract Solidity interface
 * @notice For backward compatibility - use IUnifiedRewardsTracking for new development
 */
export interface IEarningsRewardsContract {
  recordJobCompletion(jobId: string, jobValue: number, jobPoster: string): Promise<void>;
  recordGovernanceAction(user: string, actionWeight: number): Promise<void>;
  recordEarnings(user: string, amount: number): Promise<void>;
  getPendingRewards(user: string): Promise<number>;
}