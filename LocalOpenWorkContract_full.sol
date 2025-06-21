// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import { OApp, MessagingFee, Origin } from "@layerzerolabs/oapp-evm/contracts/oapp/OApp.sol";
import { MessagingReceipt } from "@layerzerolabs/oapp-evm/contracts/oapp/OAppSender.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title LocalOpenWorkV2
 * @dev LayerZero V2 OApp for managing local chain operations and cross-chain communication
 */
contract LocalOpenWorkV2 is OApp, ReentrancyGuard {
    
    // Reference to token used for payments (e.g. USDT)
    IERC20 public paymentToken;

    // Escrow balances
    mapping(uint256 => uint256) public jobEscrow;

    // Job status
    mapping(uint256 => uint8) public localJobStatus;

    // Payment status for each job milestone
    mapping(uint256 => mapping(uint256 => uint8)) public milestoneFundingStatus;

    // Events
    event UserProfileSent(uint32 indexed dstEid, address indexed user, string name, address targetContract);
    event JobCreated(uint32 indexed dstEid, uint256 indexed jobId, string title, address targetContract);
    event JobApplicationSent(uint32 indexed dstEid, uint256 indexed jobId, address applicant, address targetContract);
    event MilestoneProposalSent(uint32 indexed dstEid, uint256 indexed jobId, address applicant, address targetContract);
    event JobEscrowFunded(uint256 indexed jobId, uint256 milestoneId, uint256 amount);
    event JobPaymentReleased(uint256 indexed jobId, uint256 milestoneId, address freelancer, uint256 amount);
    event MilestoneLocked(uint256 indexed jobId, uint256 milestoneId, uint256 amount);
    event WorkSubmissionSent(uint32 indexed dstEid, uint256 indexed jobId, address freelancer, address targetContract);
    event WorkApprovalSent(uint32 indexed dstEid, uint256 submissionId, address targetContract);
    event RatingSent(uint32 indexed dstEid, uint256 indexed jobId, address rated, address targetContract);

    constructor(
        address _endpoint,
        address _owner
    ) OApp(_endpoint, _owner) Ownable(msg.sender) {
        _transferOwnership(_owner);
    }

    /**
     * @dev Set the payment token address
     */
    function setPaymentToken(address _paymentToken) external onlyOwner {
        paymentToken = IERC20(_paymentToken);
    }

    /**
     * @dev Create a user profile - sends to UserRegistry contract
     */
    function createUserProfile(
        uint32 _dstEid,
        address _userRegistryContract,
        string memory name,
        string[] memory skills,
        string memory profileHash,
        bytes calldata _options
    ) external payable nonReentrant {
        require(bytes(name).length > 0, "Name cannot be empty");
        require(skills.length > 0, "Skills cannot be empty");

        // Set peer to UserRegistry contract
        setPeer(_dstEid, bytes32(uint256(uint160(_userRegistryContract))));

        bytes memory payload = abi.encode(
            "CREATE_PROFILE",
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

        emit UserProfileSent(_dstEid, msg.sender, name, _userRegistryContract);
    }

    /**
     * @dev Post a job - sends to JobMarket contract
     */
    function postJob(
        uint32 _dstEid,
        address _jobMarketContract,
        string memory jobDetailHash,
        uint256[] memory milestonePayments,
        bytes calldata _options
    ) external payable nonReentrant {
        require(bytes(jobDetailHash).length > 0, "Job detail hash cannot be empty");
        require(milestonePayments.length > 0, "Must have at least one milestone");

        // Set peer to JobMarket contract
        setPeer(_dstEid, bytes32(uint256(uint160(_jobMarketContract))));

        bytes memory payload = abi.encode(
            "POST_JOB",
            msg.sender,
            jobDetailHash,
            milestonePayments
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

        emit JobCreated(_dstEid, 0, jobDetailHash, _jobMarketContract);
    }

    /**
     * @dev Apply to a job - sends to JobMarket contract
     */
    function applyToJob(
        uint32 _dstEid,
        address _jobMarketContract,
        uint256 jobId,
        string memory applicationHash,
        uint256[] memory milestonePayments,
        string memory milestoneDetailsHash,
        bytes calldata _options
    ) external payable nonReentrant {
        require(bytes(applicationHash).length > 0, "Application hash cannot be empty");

        // Set peer to JobMarket contract
        setPeer(_dstEid, bytes32(uint256(uint160(_jobMarketContract))));

        bytes memory payload = abi.encode(
            "APPLY_TO_JOB",
            msg.sender,
            jobId,
            applicationHash,
            milestonePayments,
            milestoneDetailsHash
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

        emit JobApplicationSent(_dstEid, jobId, msg.sender, _jobMarketContract);
    }

    /**
     * @dev Submit work - sends to JobMarket contract
     */
    function submitWork(
        uint32 _dstEid,
        address _jobMarketContract,
        uint256 jobId,
        string memory workHash,
        string memory comments,
        bytes calldata _options
    ) external payable nonReentrant {
        require(bytes(workHash).length > 0, "Work hash cannot be empty");

        // Set peer to JobMarket contract
        setPeer(_dstEid, bytes32(uint256(uint160(_jobMarketContract))));

        bytes memory payload = abi.encode(
            "SUBMIT_WORK",
            msg.sender,
            jobId,
            workHash,
            comments
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

        emit WorkSubmissionSent(_dstEid, jobId, msg.sender, _jobMarketContract);
    }

    /**
     * @dev Approve work - sends to JobMarket contract
     */
    function approveWork(
        uint32 _dstEid,
        address _jobMarketContract,
        uint256 submissionId,
        bytes calldata _options
    ) external payable nonReentrant {
        // Set peer to JobMarket contract
        setPeer(_dstEid, bytes32(uint256(uint160(_jobMarketContract))));

        bytes memory payload = abi.encode(
            "APPROVE_WORK",
            msg.sender,
            submissionId
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

        emit WorkApprovalSent(_dstEid, submissionId, _jobMarketContract);
    }

    /**
     * @dev Rate a user - sends to UserRegistry contract
     */
    function rate(
        uint32 _dstEid,
        address _userRegistryContract,
        uint256 jobId,
        address user,
        uint8 rating,
        bytes calldata _options
    ) external payable nonReentrant {
        require(rating >= 1 && rating <= 5, "Rating must be between 1 and 5");

        // Set peer to UserRegistry contract
        setPeer(_dstEid, bytes32(uint256(uint160(_userRegistryContract))));

        bytes memory payload = abi.encode(
            "RATE_USER",
            msg.sender,
            jobId,
            user,
            rating
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

        emit RatingSent(_dstEid, jobId, user, _userRegistryContract);
    }

    /**
     * @dev Fund a milestone escrow locally
     */
    function fundMilestoneEscrow(uint256 jobId, uint256 milestoneId, uint256 amount) external {
        require(address(paymentToken) != address(0), "Payment token not set");

        require(
            paymentToken.transferFrom(msg.sender, address(this), amount),
            "Token transfer failed"
        );

        jobEscrow[jobId] += amount;
        milestoneFundingStatus[jobId][milestoneId] = 1; // Funded

        emit JobEscrowFunded(jobId, milestoneId, amount);
    }

    /**
     * @dev Release payment for a milestone to a freelancer
     */
    function releaseMilestonePayment(uint256 jobId, uint256 milestoneId, address freelancer) external onlyOwner returns (uint256) {
        require(address(paymentToken) != address(0), "Payment token not set");
        require(jobEscrow[jobId] > 0, "Job not funded");
        require(milestoneFundingStatus[jobId][milestoneId] == 1, "Milestone not funded");

        uint256 payment = jobEscrow[jobId];
        jobEscrow[jobId] = 0;
        milestoneFundingStatus[jobId][milestoneId] = 2; // Payment released

        require(
            paymentToken.transfer(freelancer, payment),
            "Freelancer payment transfer failed"
        );

        emit JobPaymentReleased(jobId, milestoneId, freelancer, payment);
        return payment;
    }

    /**
     * @dev Quote fees for various functions
     */
    function quoteCreateUserProfile(
        uint32 _dstEid,
        string memory name,
        string[] memory skills,
        string memory profileHash,
        bytes calldata _options
    ) external view returns (MessagingFee memory) {
        bytes memory payload = abi.encode(
            "CREATE_PROFILE",
            msg.sender,
            name,
            skills,
            profileHash
        );
        return _quote(_dstEid, payload, _options, false);
    }

    function quotePostJob(
        uint32 _dstEid,
        string memory jobDetailHash,
        uint256[] memory milestonePayments,
        bytes calldata _options
    ) external view returns (MessagingFee memory) {
        bytes memory payload = abi.encode(
            "POST_JOB",
            msg.sender,
            jobDetailHash,
            milestonePayments
        );
        return _quote(_dstEid, payload, _options, false);
    }

    /**
     * @dev Get the escrow amount for a job
     */
    function getJobEscrow(uint256 jobId) external view returns (uint256) {
        return jobEscrow[jobId];
    }

    /**
     * @dev Recover any accidentally sent tokens
     */
    function recoverTokens(address tokenAddress, address to, uint256 amount) external onlyOwner {
        IERC20(tokenAddress).transfer(to, amount);
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