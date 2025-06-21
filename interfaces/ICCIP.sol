// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/**
 * @title ICCIP
 * @dev Interface for cross-chain communication
 */
interface ICCIP {
    struct Any2EVMMessage {
        bytes32 messageId;
        uint64 sourceChainSelector;
        bytes sender;
        bytes data;
        // Additional fields as required
    }

    /**
     * @dev Calculate the fee for a cross-chain message
     * @param destinationChainSelector The destination chain selector
     * @param receiver The receiver address
     * @param data The message data
     * @param tokenAmounts Token amounts (if any)
     * @return fee The calculated fee
     */
    function getFee(
        uint64 destinationChainSelector,
        address receiver,
        bytes calldata data,
        bytes[] calldata tokenAmounts
    ) external view returns (uint256 fee);

    /**
     * @dev Send a cross-chain message
     * @param destinationChainSelector The destination chain selector
     * @param receiver The receiver address
     * @param data The message data
     * @param tokenAmounts Token amounts (if any)
     * @return messageId The message ID
     */
    function ccipSend(
        uint64 destinationChainSelector,
        address receiver,
        bytes calldata data,
        bytes[] calldata tokenAmounts
    ) external payable returns (bytes32 messageId);

    /**
     * @dev Send a cross-chain message (legacy)
     * @param destChainId The destination chain ID
     * @param recipient The recipient address on the destination chain
     * @param data The message data
     * @return messageId A unique ID for the message
     */
    function sendMessage(
        uint64 destChainId,
        address recipient,
        bytes memory data
    ) external returns (bytes32 messageId);
}

/**
 * @title ICCIPReceiver
 * @dev Interface for contracts that receive CCIP messages
 */
interface ICCIPReceiver {
    /**
     * @dev Called when a CCIP message is received
     * @param message The received message
     */
    function ccipReceive(ICCIP.Any2EVMMessage calldata message) external;
}