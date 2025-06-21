// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/**
 * @title IOpenWorkRegistry
 * @dev Interface for the OpenWork Registry contract
 */
interface IOpenWorkRegistry {
    /**
     * @dev Resolves a dispute (only callable by Athena contract)
     * @param jobId ID of the job
     * @param winnerAddress Address of the dispute winner
     * @param loserAddress Address of the dispute loser
     * @param winnerAmount Amount to be transferred to the winner
     * @param platformFee Platform fee amount
     */
    function resolveDispute(
        uint256 jobId,
        address winnerAddress,
        address loserAddress,
        uint256 winnerAmount,
        uint256 platformFee
    ) external;
}