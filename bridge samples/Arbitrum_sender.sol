// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import { OApp, MessagingFee, Origin } from "@layerzerolabs/oapp-evm/contracts/oapp/OApp.sol";
import { MessagingReceipt } from "@layerzerolabs/oapp-evm/contracts/oapp/OAppSender.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title ArbitrumSender
 * @dev LayerZero v2 OApp for sending cross-chain messages from Arbitrum to Optimism
 */
contract ArbitrumSender is OApp {
    // Event emitted when a message is sent
    event MessageSent(
        uint32 indexed dstEid,
        bytes32 indexed guid,
        string message,
        uint256 fee
    );

    // Event emitted when a message is received (for bidirectional communication)
    event MessageReceived(
        uint32 indexed srcEid,
        bytes32 indexed guid,
        string message
    );

    // Counter for sent messages
    uint256 public messageCounter;

    // Mapping to store sent messages
    mapping(uint256 => string) public sentMessages;

    constructor(
        address _endpoint,
        address _owner
    ) OApp(_endpoint, _owner) Ownable(msg.sender) {
        _transferOwnership(_owner);
    }

    /**
     * @dev Send a cross-chain message to Optimism
     * @param _dstEid The destination endpoint ID (Optimism)
     * @param _message The message to send
     * @param _options LayerZero message options
     */
    function sendMessage(
        uint32 _dstEid,
        string calldata _message,
        bytes calldata _options
    ) external payable {
        // Encode the message
        bytes memory _payload = abi.encode(_message, msg.sender);
        
        // Quote the messaging fee
        MessagingFee memory fee = _quote(_dstEid, _payload, _options, false);
        
        require(msg.value >= fee.nativeFee, "Insufficient fee");

        // Send the message
        MessagingReceipt memory receipt = _lzSend(
            _dstEid,
            _payload,
            _options,
            MessagingFee(msg.value, 0),
            payable(msg.sender)
        );

        // Store the sent message
        messageCounter++;
        sentMessages[messageCounter] = _message;

        emit MessageSent(_dstEid, receipt.guid, _message, fee.nativeFee);
    }

    /**
     * @dev Quote the messaging fee for sending a message
     * @param _dstEid The destination endpoint ID
     * @param _message The message to send
     * @param _options LayerZero message options
     * @param _payInLzToken Whether to pay in LZ token
     * @return fee The messaging fee
     */
    function quote(
        uint32 _dstEid,
        string calldata _message,
        bytes calldata _options,
        bool _payInLzToken
    ) public view returns (MessagingFee memory fee) {
        bytes memory _payload = abi.encode(_message, msg.sender);
        return _quote(_dstEid, _payload, _options, _payInLzToken);
    }

    /**
     * @dev Internal function to handle received messages
     * @param _origin The origin information
     * @param _guid The unique identifier for the message
     * @param payload The message payload
     * @param _executor The executor address
     * @param _extraData Additional data
     */
    function _lzReceive(
        Origin calldata _origin,
        bytes32 _guid,
        bytes calldata payload,
        address _executor,
        bytes calldata _extraData
    ) internal override {
        // Decode the message
        (string memory message, address sender) = abi.decode(payload, (string, address));
        
        emit MessageReceived(_origin.srcEid, _guid, message);
    }

    /**
     * @dev Get the last sent message
     * @return The last sent message
     */
    function getLastSentMessage() external view returns (string memory) {
        require(messageCounter > 0, "No messages sent");
        return sentMessages[messageCounter];
    }

    /**
     * @dev Withdraw contract balance (owner only)
     */
    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No balance to withdraw");
        payable(owner()).transfer(balance);
    }

    /**
     * @dev Receive function to accept ETH
     */
    receive() external payable {}
}