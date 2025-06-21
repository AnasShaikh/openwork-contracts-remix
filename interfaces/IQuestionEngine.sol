// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../libraries/SkillQuestionStorage.sol";

/**
 * @title IQuestionEngine
 * @dev Interface for question/answer functionality
 */
interface IQuestionEngine {
    // Question functions
    function askAthena(
        string calldata questionHash,
        string calldata oracleName,
        uint256 fee
    ) external payable returns (uint256 questionId);
    
    function voteOnQuestion(
        uint256 questionId,
        bool inFavor,
        string calldata reasonHash
    ) external returns (bool success);
    
    function getQuestionDetails(uint256 questionId) external view returns (
        QuestionStorage.Question memory question,
        uint256 votesFor,
        uint256 votesAgainst
    );
    
    function getQuestionVotes(uint256 questionId) external view returns (uint256 votesFor, uint256 votesAgainst);
    
    function claimQuestionFeeReward(uint256 questionId) external returns (uint256 amount);
    
    function claimQuestionFeeRefund(uint256 questionId) external returns (uint256 amount);
}