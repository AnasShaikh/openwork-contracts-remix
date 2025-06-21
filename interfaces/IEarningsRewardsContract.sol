// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/**
 * @title IEarningsRewardsContract
 * @dev Legacy interface for backwards compatibility with NativeOpenWorkContract
 * This has been replaced by IUnifiedRewardsTracking, but maintained for compatibility
 */
interface IEarningsRewardsContract {
    function recordJobCompletion(bytes32 jobId, uint256 jobValue, address jobPoster) external;
    function recordGovernanceAction(address user, uint256 actionWeight) external;
    function recordEarnings(address user, uint256 amount) external;
}