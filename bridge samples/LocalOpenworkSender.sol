// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import { OApp, MessagingFee, Origin } from "@layerzerolabs/oapp-evm/contracts/oapp/OApp.sol";
import { MessagingReceipt } from "@layerzerolabs/oapp-evm/contracts/oapp/OAppSender.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/**
 * @title LocalOpenWorkV2
 * @dev LayerZero V2 OApp for managing local chain operations and cross-chain profile creation
 */
contract LocalOpenWorkV2 is OApp, ReentrancyGuard {
    
    // Events
    event UserProfileSent(uint32 indexed dstEid, address indexed user, string name);

    constructor(
        address _endpoint,
        address _owner
    ) OApp(_endpoint, _owner) Ownable(msg.sender) {
        _transferOwnership(_owner);
    }

    /**
     * @dev Create a user profile - sends a cross-chain message to the User Registry
     */
    function createUserProfile(
        uint32 _dstEid,
        string memory name,
        string[] memory skills,
        string memory profileHash,
        bytes calldata _options
    ) external payable nonReentrant {
        require(bytes(name).length > 0, "Name cannot be empty");
        require(skills.length > 0, "Skills cannot be empty");

        bytes memory payload = abi.encode(
            msg.sender,
            name,
            skills,
            profileHash
        );

        MessagingFee memory fee = _quote(_dstEid, payload, _options, false);
        require(msg.value >= fee.nativeFee, "Insufficient fee");

        _lzSend(
            _dstEid,
            payload,
            _options,
            MessagingFee(msg.value, 0),
            payable(msg.sender)
        );

        emit UserProfileSent(_dstEid, msg.sender, name);
    }

    /**
     * @dev Quote the fee for creating a user profile cross-chain
     */
    function quoteCreateUserProfile(
        uint32 _dstEid,
        string memory name,
        string[] memory skills,
        string memory profileHash,
        bytes calldata _options
    ) external view returns (MessagingFee memory) {
        bytes memory payload = abi.encode(
            msg.sender,
            name,
            skills,
            profileHash
        );
        return _quote(_dstEid, payload, _options, false);
    }

    /**
     * @dev Handle incoming LayerZero V2 messages
     */
    function _lzReceive(
        Origin calldata,
        bytes32,
        bytes calldata,
        address,
        bytes calldata
    ) internal override {}

    /**
     * @dev Allow contract to receive Ether for LayerZero fees
     */
    receive() external payable {}
}