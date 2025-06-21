// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../libraries/DisputeOracleStorage.sol";

/**
 * @title IDisputeEngine
 * @dev Interface for dispute resolution functionality
 */
interface IDisputeEngine {
    // Dispute functions
    function raiseDispute(
        uint256 jobId,
        string calldata disputeHash,
        string calldata oracleName,
        uint256 fee
    ) external payable returns (uint256 disputeId);
    
    function createDispute(uint256 jobId, string memory reason, string memory oracleName) external payable returns (uint256);
    
    function submitEvidence(uint256 disputeId, string calldata evidenceHash) external returns (bool success);
    
    function voteOnDispute(uint256 disputeId, bool inFavor, string calldata reasonHash) external returns (bool success);
    
    function resolveDispute(uint256 disputeId, address recipient) external returns (bool success);
    
    function escalateDispute(uint256 disputeId) external returns (bool success);
    
    // Dispute query functions
    function getDisputeDetails(uint256 disputeId) external view returns (
        DisputeStorage.Dispute memory dispute,
        uint256 votesFor,
        uint256 votesAgainst
    );
    
    function getDisputeStatus(uint256 disputeId) external view returns (DisputeStorage.DisputeStatus status);
    
    function getDisputeVotes(uint256 disputeId) external view returns (uint256 votesFor, uint256 votesAgainst);
    
    function checkDisputeParticipation(uint256 disputeId, address voter) external view returns (
        bool isInitiator, 
        bool isRespondent
    );
    
    function claimDisputedAmount(uint256 disputeId) external returns (uint256 amount);

    function claimDisputeFeeRefund(uint256 disputeId) external returns (uint256 amount);
    
    function claimDisputeFeeReward(uint256 disputeId) external returns (uint256 amount);
}