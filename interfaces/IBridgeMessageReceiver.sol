// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/**
 * @title IBridgeMessageReceiver
 * @dev Interface for contracts that receive cross-chain messages from a bridge
 */
interface IBridgeMessageReceiver {
    /**
     * @dev Receives cross-chain messages
     * @param srcChainId Chain ID of the source chain
     * @param srcAddress Address of the source contract
     * @param payload Encoded message payload
     * @return success Whether the message was processed successfully
     */
    function receiveCrossChainMessage(
        uint16 srcChainId,
        address srcAddress,
        bytes calldata payload
    ) external returns (bool success);
}