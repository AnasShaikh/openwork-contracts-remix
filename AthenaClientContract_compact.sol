// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import { OApp, MessagingFee, Origin } from "@layerzerolabs/oapp-evm/contracts/oapp/OApp.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/**
 * @title AthenaClientContract
 * @dev LayerZero V2 OApp for interacting with the Athena dispute resolution service
 */
contract AthenaClientContract is OApp, ReentrancyGuard {
    /* -------------------------------------------------------------------------- */
    /*                                   STATE                                    */
    /* -------------------------------------------------------------------------- */
    IERC20 public immutable usdToken;   // e.g. USDT / USDC
    uint32 public dstEid;               // Destination chain ID for Athena

    /* -------------------------------------------------------------------------- */
    /*                                   EVENTS                                   */
    /* -------------------------------------------------------------------------- */
    event DisputeRaised(
        uint32 indexed dstEid,
        address indexed user,
        uint256 jobId,
        uint256 disputedAmount,
        string disputeHash,
        string oracleName,
        uint256 usdtFee
    );
    event SkillVerificationRequested(
        uint32 indexed dstEid,
        address indexed user,
        string skill,
        string proofHash,
        uint256 usdtFee
    );
    event DisputedAmountClaimed(
        uint32 indexed dstEid,
        address indexed user,
        uint256 disputeId
    );
    event QuestionAsked(
        uint32 indexed dstEid,
        address indexed user,
        string question,
        string contextHash,
        string oracleName,
        uint256 usdtFee
    );
    event DisputeCreated(
        uint32 indexed dstEid,
        address indexed user,
        uint256 jobId,
        string reason
    );
    event FeesWithdrawn(address indexed to, uint256 amount);

    /* -------------------------------------------------------------------------- */
    /*                                CONSTRUCTOR                                 */
    /* -------------------------------------------------------------------------- */
    constructor(
        address _endpoint,
        address _owner,
        address _usdToken,
        uint32 _dstEid
    ) OApp(_endpoint, _owner) Ownable(_owner) {
        usdToken = IERC20(_usdToken);
        dstEid = _dstEid;
    }

    /* -------------------------------------------------------------------------- */
    /*                              ADMIN FUNCTIONS                               */
    /* -------------------------------------------------------------------------- */
    function setDstEid(uint32 _dstEid) external onlyOwner {
        require(_dstEid > 0, "Invalid destination EID");
        dstEid = _dstEid;
    }

    /* -------------------------------------------------------------------------- */
    /*                              DISPUTE FUNCTIONS                             */
    /* -------------------------------------------------------------------------- */
    /**
     * @dev Raise a dispute
     * @param jobId The ID of the job
     * @param disputedAmount The amount being disputed (for tracking purposes)
     * @param disputeHash Hash of the dispute details
     * @param oracleName Name of the oracle to use
     * @param usdtFee Amount of USDT caller wants to deposit
     * @param _options LayerZero options
     */
    function raiseDispute(
        uint256 jobId,
        uint256 disputedAmount,
        string memory disputeHash,
        string memory oracleName,
        uint256 usdtFee,
        bytes calldata _options
    ) external payable nonReentrant {
        require(bytes(disputeHash).length > 0, "Dispute hash empty");
        require(bytes(oracleName).length > 0, "Oracle name empty");
        require(usdtFee > 0, "USDT fee zero");
        require(disputedAmount > 0, "Disputed amount zero");

        // Pull caller-specified USDT fee
        require(
            usdToken.transferFrom(msg.sender, address(this), usdtFee),
            "USDT transfer failed"
        );

        // Prepare cross-chain payload
        bytes memory payload = abi.encode("raiseDispute", msg.sender, jobId, disputedAmount, disputeHash, oracleName, usdtFee);

        // Pay LayerZero native gas fee
        MessagingFee memory fee = _quote(dstEid, payload, _options, false);
        require(msg.value >= fee.nativeFee, "Native fee too low");

        _lzSend(
            dstEid,
            payload,
            _options,
            MessagingFee(msg.value, 0),
            payable(msg.sender)
        );

        emit DisputeRaised(dstEid, msg.sender, jobId, disputedAmount, disputeHash, oracleName, usdtFee);
    }

    /**
     * @dev Claim disputed amount from a resolved dispute
     * @param disputeId The ID of the dispute
     * @param _options LayerZero options
     */
    function claimDisputedAmount(
        uint256 disputeId,
        bytes calldata _options
    ) external payable nonReentrant {
        // Prepare cross-chain payload
        bytes memory payload = abi.encode("claimDisputedAmount", msg.sender, disputeId);

        // Pay LayerZero native gas fee
        MessagingFee memory fee = _quote(dstEid, payload, _options, false);
        require(msg.value >= fee.nativeFee, "Native fee too low");

        _lzSend(
            dstEid,
            payload,
            _options,
            MessagingFee(msg.value, 0),
            payable(msg.sender)
        );

        emit DisputedAmountClaimed(dstEid, msg.sender, disputeId);
    }

    /* -------------------------------------------------------------------------- */
    /*                              SKILL FUNCTIONS                               */
    /* -------------------------------------------------------------------------- */
    /**
     * @dev Request skill verification
     * @param skill The skill to verify
     * @param proofHash Hash of the proof
     * @param usdtFee Amount of USDT caller wants to deposit
     * @param _options LayerZero options
     */
    function requestSkillVerification(
        string memory skill,
        string memory proofHash,
        uint256 usdtFee,
        bytes calldata _options
    ) external payable nonReentrant {
        require(bytes(skill).length > 0, "Skill empty");
        require(bytes(proofHash).length > 0, "Proof hash empty");
        require(usdtFee > 0, "USDT fee zero");

        // Pull caller-specified USDT fee
        require(
            usdToken.transferFrom(msg.sender, address(this), usdtFee),
            "USDT transfer failed"
        );

        // Prepare cross-chain payload
        bytes memory payload = abi.encode("requestSkillVerification", msg.sender, skill, proofHash, usdtFee);

        // Pay LayerZero native gas fee
        MessagingFee memory fee = _quote(dstEid, payload, _options, false);
        require(msg.value >= fee.nativeFee, "Native fee too low");

        _lzSend(
            dstEid,
            payload,
            _options,
            MessagingFee(msg.value, 0),
            payable(msg.sender)
        );

        emit SkillVerificationRequested(dstEid, msg.sender, skill, proofHash, usdtFee);
    }

    /* -------------------------------------------------------------------------- */
    /*                              QUESTION FUNCTIONS                            */
    /* -------------------------------------------------------------------------- */
    /**
     * @dev Ask a question to Athena
     * @param question The question to ask
     * @param contextHash Hash of additional context for the question
     * @param oracleName Name of the oracle to use
     * @param usdtFee Amount of USDT caller wants to deposit
     * @param _options LayerZero options
     */
    function askAthena(
        string memory question,
        string memory contextHash,
        string memory oracleName,
        uint256 usdtFee,
        bytes calldata _options
    ) external payable nonReentrant {
        require(bytes(question).length > 0, "Question empty");
        require(bytes(oracleName).length > 0, "Oracle name empty");
        require(usdtFee > 0, "USDT fee zero");

        // Pull caller-specified USDT fee
        require(
            usdToken.transferFrom(msg.sender, address(this), usdtFee),
            "USDT transfer failed"
        );

        // Prepare cross-chain payload
        bytes memory payload = abi.encode("askAthena", msg.sender, question, contextHash, oracleName, usdtFee);

        // Pay LayerZero native gas fee
        MessagingFee memory fee = _quote(dstEid, payload, _options, false);
        require(msg.value >= fee.nativeFee, "Native fee too low");

        _lzSend(
            dstEid,
            payload,
            _options,
            MessagingFee(msg.value, 0),
            payable(msg.sender)
        );

        emit QuestionAsked(dstEid, msg.sender, question, contextHash, oracleName, usdtFee);
    }

    /* -------------------------------------------------------------------------- */
    /*                              QUOTE FUNCTIONS                               */
    /* -------------------------------------------------------------------------- */
    function quoteRaiseDispute(
        uint256 jobId,
        uint256 disputedAmount,
        string memory disputeHash,
        string memory oracleName,
        uint256 usdtFee,
        bytes calldata _options
    ) external view returns (MessagingFee memory) {
        bytes memory payload = abi.encode("raiseDispute", msg.sender, jobId, disputedAmount, disputeHash, oracleName, usdtFee);
        return _quote(dstEid, payload, _options, false);
    }

    function quoteCreateDispute(
        uint256 jobId,
        string memory reason,
        bytes calldata _options
    ) external view returns (MessagingFee memory) {
        bytes memory payload = abi.encode("createDispute", msg.sender, jobId, reason);
        return _quote(dstEid, payload, _options, false);
    }

    function quoteClaimDisputedAmount(
        uint256 disputeId,
        bytes calldata _options
    ) external view returns (MessagingFee memory) {
        bytes memory payload = abi.encode("claimDisputedAmount", msg.sender, disputeId);
        return _quote(dstEid, payload, _options, false);
    }

    function quoteRequestSkillVerification(
        string memory skill,
        string memory proofHash,
        uint256 usdtFee,
        bytes calldata _options
    ) external view returns (MessagingFee memory) {
        bytes memory payload = abi.encode("requestSkillVerification", msg.sender, skill, proofHash, usdtFee);
        return _quote(dstEid, payload, _options, false);
    }

    function quoteAskAthena(
        string memory question,
        string memory contextHash,
        string memory oracleName,
        uint256 usdtFee,
        bytes calldata _options
    ) external view returns (MessagingFee memory) {
        bytes memory payload = abi.encode("askAthena", msg.sender, question, contextHash, oracleName, usdtFee);
        return _quote(dstEid, payload, _options, false);
    }

    /* -------------------------------------------------------------------------- */
    /*                               FEE WITHDRAWAL                               */
    /* -------------------------------------------------------------------------- */
    function withdrawFees(address to, uint256 amount) external onlyOwner {
        require(usdToken.transfer(to, amount), "Withdraw failed");
        emit FeesWithdrawn(to, amount);
    }

    /* -------------------------------------------------------------------------- */
    /*                        LAYERZERO RECEIVE HOOK                             */
    /* -------------------------------------------------------------------------- */
    function _lzReceive(
        Origin calldata,
        bytes32,
        bytes calldata _message,
        address,
        bytes calldata
    ) internal override {
        // Handle responses from dispute resolution contract
        // This could include dispute resolution results, claim approvals, etc.
        (string memory action, address user, uint256 id, bool result) = 
            abi.decode(_message, (string, address, uint256, bool));
        
        // Handle different response types
        if (keccak256(bytes(action)) == keccak256(bytes("disputeResolved"))) {
            // Handle dispute resolution result
            // Could trigger fund transfers based on result
        }
    }

    /* -------------------------------------------------------------------------- */
    /*                                  FALLBACK                                  */
    /* -------------------------------------------------------------------------- */
    receive() external payable {}
}