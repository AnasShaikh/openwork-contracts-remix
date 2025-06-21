// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import { OApp, MessagingFee, Origin } from "@layerzerolabs/oapp-evm/contracts/oapp/OApp.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/**
 * @title LocalOpenWorkV2
 * @dev LayerZero V2 OApp that lets **each caller decide the USDT fee** they deposit with the
 *      profile-creation message.  The fee is passed as a parameter, pulled via `transferFrom`,
 *      and retained in this contract.
 */
contract LocalOpenWorkV2 is OApp, ReentrancyGuard {
    /* -------------------------------------------------------------------------- */
    /*                                   STATE                                    */
    /* -------------------------------------------------------------------------- */
    IERC20 public immutable usdToken;   // e.g. USDT / USDC

    /* -------------------------------------------------------------------------- */
    /*                                   EVENTS                                   */
    /* -------------------------------------------------------------------------- */
    event UserProfileSent(
        uint32 indexed dstEid,
        address indexed user,
        string name,
        uint256 usdtFee
    );
    event FeesWithdrawn(address indexed to, uint256 amount);

    /* -------------------------------------------------------------------------- */
    /*                                CONSTRUCTOR                                 */
    /* -------------------------------------------------------------------------- */
    constructor(
        address _endpoint,
        address _owner,
        address _usdToken
    ) OApp(_endpoint, _owner) Ownable(_owner) {
        usdToken = IERC20(_usdToken);
    }

    /* -------------------------------------------------------------------------- */
    /*                       CREATE PROFILE  (CALLER-CHOSEN FEE)                   */
    /* -------------------------------------------------------------------------- */
    /**
     * @param _dstEid     LayerZero destination chain ID
     * @param name        User name
     * @param skills      Array of skills
     * @param profileHash IPFS / Arweave hash
     * @param usdtFee     Amount of USDT caller wants to deposit (6-dec units)
     * @param _options    LayerZero options (e.g., gas limits); pass empty bytes if unsure
     */
    function createUserProfile(
        uint32 _dstEid,
        string memory name,
        string[] memory skills,
        string memory profileHash,
        uint256 usdtFee,
        bytes calldata _options
    ) external payable nonReentrant {
        require(bytes(name).length > 0, "Name empty");
        require(skills.length > 0, "Skills empty");
        require(usdtFee > 0, "USDT fee zero");

        /* ---- pull caller-specified USDT fee ---- */
        require(
            usdToken.transferFrom(msg.sender, address(this), usdtFee),
            "USDT transfer failed"
        );

        /* ---- prepare cross-chain payload ---- */
        bytes memory payload = abi.encode(msg.sender, name, skills, profileHash);

        /* ---- pay LayerZero native gas fee ---- */
        MessagingFee memory fee = _quote(_dstEid, payload, _options, false);
        require(msg.value >= fee.nativeFee, "Native fee too low");

        _lzSend(
            _dstEid,
            payload,
            _options,
            MessagingFee(msg.value, 0),
            payable(msg.sender)
        );

        emit UserProfileSent(_dstEid, msg.sender, name, usdtFee);
    }

    /* -------------------------------------------------------------------------- */
    /*                              VIEW NATIVE FEE                               */
    /* -------------------------------------------------------------------------- */
    function quoteCreateUserProfile(
        uint32 _dstEid,
        string memory name,
        string[] memory skills,
        string memory profileHash,
        bytes calldata _options
    ) external view returns (MessagingFee memory) {
        return _quote(_dstEid, abi.encode(msg.sender, name, skills, profileHash), _options, false);
    }

    /* -------------------------------------------------------------------------- */
    /*                               FEE WITHDRAWAL                               */
    /* -------------------------------------------------------------------------- */
    function withdrawFees(address to, uint256 amount) external onlyOwner {
        require(usdToken.transfer(to, amount), "Withdraw failed");
        emit FeesWithdrawn(to, amount);
    }

    /* -------------------------------------------------------------------------- */
    /*                        LAYERZERO RECEIVE HOOK (unused)                     */
    /* -------------------------------------------------------------------------- */
    function _lzReceive(
        Origin calldata,
        bytes32,
        bytes calldata,
        address,
        bytes calldata
    ) internal override {}

    /* -------------------------------------------------------------------------- */
    /*                                  FALLBACK                                  */
    /* -------------------------------------------------------------------------- */
    receive() external payable {}
}
