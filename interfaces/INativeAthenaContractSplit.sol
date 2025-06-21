// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IDisputeEngine.sol";
import "./IOracleEngine.sol";
import "./ISkillVerification.sol";
import "./IQuestionEngine.sol";

/**
 * @title INativeAthenaContractSplit
 * @dev Combined interface for all Athena functionality to maintain compatibility
 */
interface INativeAthenaContractSplit is 
    IDisputeEngine, 
    IOracleEngine, 
    ISkillVerification, 
    IQuestionEngine 
{
    // This interface combines all functionality to maintain compatibility with existing code
    // New contracts can implement only the relevant interfaces
}