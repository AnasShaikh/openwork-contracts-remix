// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/**
 * @title ICrossChainBridge
 * @dev Interface for contracts that send cross-chain messages via a bridge
 */
interface ICrossChainBridge {
    /**
     * @dev Sends a cross-chain message
     * @param payload The message payload to send
     * @return messageId Unique identifier for the sent message
     */
    function sendMessage(bytes memory payload) external returns (bytes32 messageId);
}