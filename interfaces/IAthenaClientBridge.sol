// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title IAthenaClientBridge
 * @dev Interface for the Athena client bridge using LayerZero
 */
interface IAthenaClientBridge {
    /**
     * @dev Estimate the fee for sending a message
     * @param destinationChainId LayerZero chain ID of the destination chain
     * @param receiver Address of the receiver on the destination chain
     * @param data Function call data
     * @return fee Fee for sending the message
     */
    function estimateFee(
        uint16 destinationChainId,
        address receiver,
        bytes calldata data
    ) external view returns (uint256 fee);
    
    /**
     * @dev Send a message to another chain
     * @param destinationChainId LayerZero chain ID of the destination chain
     * @param receiver Address of the receiver on the destination chain
     * @param data Function call data
     * @return messageId ID of the message
     */
    function sendMessage(
        uint16 destinationChainId,
        address receiver,
        bytes calldata data
    ) external payable returns (bytes32 messageId);
    
    /**
     * @dev Set whether a contract is trusted to send messages
     * @param chainId The chain ID
     * @param contractAddress The contract address
     * @param trusted Whether the contract is trusted
     */
    function setTrustedContract(
        uint16 chainId,
        address contractAddress,
        bool trusted
    ) external;
    
    /**
     * @dev Set whether a receiver is trusted to receive messages
     * @param chainId The chain ID
     * @param receiverAddress The receiver address
     * @param trusted Whether the receiver is trusted
     */
    function setTrustedReceiver(
        uint16 chainId,
        address receiverAddress,
        bool trusted
    ) external;
}
