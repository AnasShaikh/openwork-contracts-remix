// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

interface IStringSender {
    function sendString(uint32 _dstEid, string calldata _message, bytes calldata _options) external payable;
}

contract StringSenderCaller {
    IStringSender public stringSender;
    
    constructor(address _stringSender) {
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
}