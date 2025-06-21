// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

interface IStringSender {
    function sendString(uint32 _dstEid, string calldata _message, bytes calldata _options) external payable;
}

contract StringSenderCaller is Initializable, UUPSUpgradeable, OwnableUpgradeable {
    IStringSender public stringSender;
    
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }
    
    function initialize(address _stringSender) public initializer {
        __Ownable_init(msg.sender);
        __UUPSUpgradeable_init();
        stringSender = IStringSender(_stringSender);
    }
    
    function callSendString(
        uint32 _dstEid, 
        string calldata _message, 
        bytes calldata _options
    ) external payable {
        try stringSender.sendString{value: msg.value}(_dstEid, _message, _options) {
            // Success
        } catch Error(string memory reason) {
            revert(string(abi.encodePacked("Call failed: ", reason)));
        } catch {
            revert("Call failed with unknown error");
        }
    }
    
    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}
}