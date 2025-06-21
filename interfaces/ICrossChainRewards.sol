// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title ICrossChainRewards
 * @dev Interface for cross-chain rewards functionality
 */
interface ICrossChainRewards {
    /**
     * @dev Handle incoming message from another chain
     * @param srcChainId Source chain ID
     * @param srcAddress Source contract address
     * @param payload Message payload
     * @param messageId Unique message ID
     */
    function receiveMessage(
        uint16 srcChainId,
        address srcAddress,
        bytes calldata payload,
        bytes32 messageId
    ) external;
}