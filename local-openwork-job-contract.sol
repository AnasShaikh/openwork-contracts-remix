// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import { OApp, MessagingFee, Origin } from "@layerzerolabs/oapp-evm/contracts/oapp/OApp.sol";
import { MessagingReceipt } from "@layerzerolabs/oapp-evm/contracts/oapp/OAppSender.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

interface IRewardsTrackingContract {
    function updateRewards(uint256 jobId, uint256 paidAmountUSDT) external;
}

contract LocalOpenWorkJobContract is OApp, ReentrancyGuard {
    using SafeERC20 for IERC20;
    
    struct Profile {
        address userAddress;
        string ipfsHash;
        address referrerAddress;
        uint256 rating;
        string[] portfolioHashes;
    }
    
    struct MilestonePayment {
        string descriptionHash;
        uint256 amount;
    }
    
    struct Application {
        uint256 id;
        uint256 jobId;
        address applicant;
        string applicationHash;
        MilestonePayment[] proposedMilestones;
    }
    
    struct Job {
        uint256 id;
        address jobGiver;
        address[] applicants;
        string jobDetailHash;
        bool isOpen;
        string[] workSubmissions;
        MilestonePayment[] milestonePayments;
        MilestonePayment[] finalMilestones;
        uint256 totalPaid;
        uint256 currentLockedAmount;
        uint256 currentMilestone;
        address selectedApplicant;
        uint256 selectedApplicationId;
        uint256 totalEscrowed; // Total USDT escrowed for this job
        uint256 totalReleased; // Total USDT released for this job
    }
    
    // State variables
    mapping(address => Profile) public profiles;
    mapping(address => bool) public hasProfile;
    mapping(uint256 => Job) public jobs;
    mapping(uint256 => mapping(uint256 => Application)) public jobApplications;
    mapping(uint256 => uint256) public jobApplicationCounter;
    mapping(uint256 => mapping(address => uint256)) public jobRatings;
    mapping(address => uint256[]) public userRatings;
    uint256 public jobCounter;
    
    // Cross-chain and USDT specific
    IERC20 public immutable usdtToken;
    uint32 public nojcEndpointId; // Endpoint ID for NOJC chain
    IRewardsTrackingContract public rewardsContract;
    
    // Events
    event ProfileCreated(address indexed user, string ipfsHash, address referrer);
    event JobPosted(uint256 indexed jobId, address indexed jobGiver, string jobDetailHash, uint256 totalAmount);
    event JobApplication(uint256 indexed jobId, uint256 indexed applicationId, address indexed applicant, string applicationHash);
    event JobStarted(uint256 indexed jobId, uint256 indexed applicationId, address indexed selectedApplicant, bool useApplicantMilestones);
    event WorkSubmitted(uint256 indexed jobId, address indexed applicant, string submissionHash, uint256 milestone);
    event PaymentReleased(uint256 indexed jobId, address indexed jobGiver, address indexed applicant, uint256 amount, uint256 milestone);
    event MilestoneLocked(uint256 indexed jobId, uint256 newMilestone, uint256 lockedAmount);
    event UserRated(uint256 indexed jobId, address indexed rater, address indexed rated, uint256 rating);
    event PortfolioAdded(address indexed user, string portfolioHash);
    event USDTEscrowed(uint256 indexed jobId, address indexed jobGiver, uint256 amount);
    event CrossChainMessageSent(uint256 indexed jobId, string messageType, uint32 dstEid);
    
    constructor(
        address _endpoint,
        address _owner,
        address _usdtToken,
        uint32 _nojcEndpointId
    ) OApp(_endpoint, _owner) Ownable(_owner) {
        usdtToken = IERC20(_usdtToken);
        nojcEndpointId = _nojcEndpointId;
    }
    
    function setRewardsContract(address _rewardsContract) external onlyOwner {
        rewardsContract = IRewardsTrackingContract(_rewardsContract);
    }
    
    function setNojcEndpointId(uint32 _nojcEndpointId) external onlyOwner {
        nojcEndpointId = _nojcEndpointId;
    }
    
    // Profile Management
    function createProfile(
        string memory _ipfsHash, 
        address _referrerAddress, 
        uint256 _rating,
        bytes calldata _options
    ) external payable nonReentrant {
        require(!hasProfile[msg.sender], "Profile already exists");
        
        profiles[msg.sender] = Profile({
            userAddress: msg.sender,
            ipfsHash: _ipfsHash,
            referrerAddress: _referrerAddress,
            rating: _rating,
            portfolioHashes: new string[](0)
        });
        
        hasProfile[msg.sender] = true;
        
        // Send cross-chain message to NOJC
        bytes memory payload = abi.encode(
            "CREATE_PROFILE",
            msg.sender,
            _ipfsHash,
            _referrerAddress,
            _rating
        );
        
        MessagingFee memory fee = _quote(nojcEndpointId, payload, _options, false);
        require(msg.value >= fee.nativeFee, "Insufficient fee for cross-chain message");
        
        _lzSend(
            nojcEndpointId,
            payload,
            _options,
            MessagingFee(msg.value, 0),
            payable(msg.sender)
        );
        
        emit ProfileCreated(msg.sender, _ipfsHash, _referrerAddress);
        emit CrossChainMessageSent(0, "CREATE_PROFILE", nojcEndpointId);
    }
    
    function getProfile(address _user) public view returns (Profile memory) {
        require(hasProfile[_user], "Profile does not exist");
        return profiles[_user];
    }
    
    // Job Management
    function postJob(
        string memory _jobDetailHash, 
        MilestonePayment[] memory _milestonePayments,
        bytes calldata _options
    ) external payable nonReentrant {
        require(hasProfile[msg.sender], "Must have profile to post job");
        require(_milestonePayments.length > 0, "Must have at least one milestone");
        
        uint256 totalAmount = 0;
        for (uint i = 0; i < _milestonePayments.length; i++) {
            totalAmount += _milestonePayments[i].amount;
        }
        require(totalAmount > 0, "Total amount must be greater than 0");
        
        // Transfer USDT to contract for escrow
        usdtToken.safeTransferFrom(msg.sender, address(this), totalAmount);
        
        jobCounter++;
        Job storage newJob = jobs[jobCounter];
        newJob.id = jobCounter;
        newJob.jobGiver = msg.sender;
        newJob.jobDetailHash = _jobDetailHash;
        newJob.isOpen = true;
        newJob.totalPaid = 0;
        newJob.currentLockedAmount = totalAmount;
        newJob.currentMilestone = 0;
        newJob.selectedApplicant = address(0);
        newJob.selectedApplicationId = 0;
        newJob.totalEscrowed = totalAmount;
        newJob.totalReleased = 0;
        
        for (uint i = 0; i < _milestonePayments.length; i++) {
            newJob.milestonePayments.push(_milestonePayments[i]);
        }
        
        // Send cross-chain message to NOJC
        bytes memory payload = abi.encode(
            "POST_JOB",
            msg.sender,
            _jobDetailHash,
            _milestonePayments,
            totalAmount
        );
        
        MessagingFee memory fee = _quote(nojcEndpointId, payload, _options, false);
        require(msg.value >= fee.nativeFee, "Insufficient fee for cross-chain message");
        
        _lzSend(
            nojcEndpointId,
            payload,
            _options,
            MessagingFee(msg.value, 0),
            payable(msg.sender)
        );
        
        emit JobPosted(jobCounter, msg.sender, _jobDetailHash, totalAmount);
        emit USDTEscrowed(jobCounter, msg.sender, totalAmount);
        emit CrossChainMessageSent(jobCounter, "POST_JOB", nojcEndpointId);
    }
    
    function getJob(uint256 _jobId) public view returns (Job memory) {
        require(jobs[_jobId].id != 0, "Job does not exist");
        return jobs[_jobId];
    }
    
    // Application Management
    function applyToJob(
        uint256 _jobId, 
        string memory _applicationHash, 
        MilestonePayment[] memory _proposedMilestones,
        bytes calldata _options
    ) external payable nonReentrant {
        require(hasProfile[msg.sender], "Must have profile to apply");
        require(jobs[_jobId].id != 0, "Job does not exist");
        require(jobs[_jobId].isOpen, "Job is not open");
        require(jobs[_jobId].jobGiver != msg.sender, "Cannot apply to own job");
        require(_proposedMilestones.length > 0, "Must propose at least one milestone");
        
        // Check if already applied
        for (uint i = 0; i < jobs[_jobId].applicants.length; i++) {
            require(jobs[_jobId].applicants[i] != msg.sender, "Already applied to this job");
        }
        
        jobs[_jobId].applicants.push(msg.sender);
        
        // Create application
        jobApplicationCounter[_jobId]++;
        uint256 applicationId = jobApplicationCounter[_jobId];
        
        Application storage newApplication = jobApplications[_jobId][applicationId];
        newApplication.id = applicationId;
        newApplication.jobId = _jobId;
        newApplication.applicant = msg.sender;
        newApplication.applicationHash = _applicationHash;
        
        for (uint i = 0; i < _proposedMilestones.length; i++) {
            newApplication.proposedMilestones.push(_proposedMilestones[i]);
        }
        
        // Send cross-chain message to NOJC
        bytes memory payload = abi.encode(
            "APPLY_TO_JOB",
            msg.sender,
            _jobId,
            _applicationHash,
            _proposedMilestones
        );
        
        MessagingFee memory fee = _quote(nojcEndpointId, payload, _options, false);
        require(msg.value >= fee.nativeFee, "Insufficient fee for cross-chain message");
        
        _lzSend(
            nojcEndpointId,
            payload,
            _options,
            MessagingFee(msg.value, 0),
            payable(msg.sender)
        );
        
        emit JobApplication(_jobId, applicationId, msg.sender, _applicationHash);
        emit CrossChainMessageSent(_jobId, "APPLY_TO_JOB", nojcEndpointId);
    }
    
    function getApplication(uint256 _jobId, uint256 _applicationId) public view returns (Application memory) {
        require(jobApplications[_jobId][_applicationId].id != 0, "Application does not exist");
        return jobApplications[_jobId][_applicationId];
    }
    
    // Job Execution
    function startJob(
        uint256 _applicationId, 
        bool _useApplicantMilestones,
        bytes calldata _options
    ) external payable nonReentrant {
        // Get the application to find the job
        uint256 jobId = 0;
        for (uint256 i = 1; i <= jobCounter; i++) {
            if (jobApplications[i][_applicationId].id == _applicationId) {
                jobId = i;
                break;
            }
        }
        require(jobId != 0, "Application does not exist");
        
        Application storage application = jobApplications[jobId][_applicationId];
        Job storage job = jobs[jobId];
        
        require(job.jobGiver == msg.sender, "Only job giver can start job");
        require(job.isOpen, "Job is not open");
        require(application.applicant != address(0), "Invalid application");
        
        // Set selected applicant and application
        job.selectedApplicant = application.applicant;
        job.selectedApplicationId = _applicationId;
        job.isOpen = false;
        job.currentMilestone = 1;
        
        // Choose and store final milestones
        if (_useApplicantMilestones) {
            for (uint i = 0; i < application.proposedMilestones.length; i++) {
                job.finalMilestones.push(application.proposedMilestones[i]);
            }
        } else {
            for (uint i = 0; i < job.milestonePayments.length; i++) {
                job.finalMilestones.push(job.milestonePayments[i]);
            }
        }
        
        // Send cross-chain message to NOJC
        bytes memory payload = abi.encode(
            "START_JOB",
            msg.sender,
            _applicationId,
            _useApplicantMilestones
        );
        
        MessagingFee memory fee = _quote(nojcEndpointId, payload, _options, false);
        require(msg.value >= fee.nativeFee, "Insufficient fee for cross-chain message");
        
        _lzSend(
            nojcEndpointId,
            payload,
            _options,
            MessagingFee(msg.value, 0),
            payable(msg.sender)
        );
        
        emit JobStarted(jobId, _applicationId, application.applicant, _useApplicantMilestones);
        emit CrossChainMessageSent(jobId, "START_JOB", nojcEndpointId);
    }
    
    function submitWork(
        uint256 _jobId, 
        string memory _submissionHash,
        bytes calldata _options
    ) external payable nonReentrant {
        require(jobs[_jobId].id != 0, "Job does not exist");
        require(!jobs[_jobId].isOpen, "Job must be started");
        require(jobs[_jobId].selectedApplicant == msg.sender, "Only selected applicant can submit work");
        require(jobs[_jobId].currentMilestone <= jobs[_jobId].finalMilestones.length, "All milestones completed");
        
        jobs[_jobId].workSubmissions.push(_submissionHash);
        
        // Send cross-chain message to NOJC
        bytes memory payload = abi.encode(
            "SUBMIT_WORK",
            msg.sender,
            _jobId,
            _submissionHash
        );
        
        MessagingFee memory fee = _quote(nojcEndpointId, payload, _options, false);
        require(msg.value >= fee.nativeFee, "Insufficient fee for cross-chain message");
        
        _lzSend(
            nojcEndpointId,
            payload,
            _options,
            MessagingFee(msg.value, 0),
            payable(msg.sender)
        );
        
        emit WorkSubmitted(_jobId, msg.sender, _submissionHash, jobs[_jobId].currentMilestone);
        emit CrossChainMessageSent(_jobId, "SUBMIT_WORK", nojcEndpointId);
    }
    
    function releasePayment(
        uint256 _jobId, 
        uint256 _amount,
        bytes calldata _options
    ) external payable nonReentrant {
        require(jobs[_jobId].id != 0, "Job does not exist");
        require(jobs[_jobId].jobGiver == msg.sender, "Only job giver can release payment");
        require(!jobs[_jobId].isOpen, "Job must be started");
        require(jobs[_jobId].selectedApplicant != address(0), "No applicant selected");
        require(jobs[_jobId].currentMilestone <= jobs[_jobId].finalMilestones.length, "All milestones completed");
        require(_amount > 0, "Amount must be greater than 0");
        require(jobs[_jobId].totalReleased + _amount <= jobs[_jobId].totalEscrowed, "Cannot release more than escrowed");
        
        // Transfer USDT to the selected applicant
        usdtToken.safeTransfer(jobs[_jobId].selectedApplicant, _amount);
        
        // Update job state
        jobs[_jobId].totalPaid += _amount;
        jobs[_jobId].totalReleased += _amount;
        
        // Update rewards
        if (address(rewardsContract) != address(0)) {
            rewardsContract.updateRewards(_jobId, _amount);
        }
        
        // Send cross-chain message to NOJC
        bytes memory payload = abi.encode(
            "RELEASE_PAYMENT",
            msg.sender,
            _jobId,
            _amount
        );
        
        MessagingFee memory fee = _quote(nojcEndpointId, payload, _options, false);
        require(msg.value >= fee.nativeFee, "Insufficient fee for cross-chain message");
        
        _lzSend(
            nojcEndpointId,
            payload,
            _options,
            MessagingFee(msg.value, 0),
            payable(msg.sender)
        );
        
        emit PaymentReleased(_jobId, msg.sender, jobs[_jobId].selectedApplicant, _amount, jobs[_jobId].currentMilestone);
        emit CrossChainMessageSent(_jobId, "RELEASE_PAYMENT", nojcEndpointId);
    }
    
    function lockNextMilestone(
        uint256 _jobId, 
        uint256 _lockedAmount,
        bytes calldata _options
    ) external payable nonReentrant {
        require(jobs[_jobId].id != 0, "Job does not exist");
        require(!jobs[_jobId].isOpen, "Job must be started");
        require(jobs[_jobId].currentMilestone < jobs[_jobId].finalMilestones.length, "All milestones already completed");
        
        // Increment to next milestone
        jobs[_jobId].currentMilestone += 1;
        jobs[_jobId].currentLockedAmount = _lockedAmount;
        
        // Send cross-chain message to NOJC
        bytes memory payload = abi.encode(
            "LOCK_NEXT_MILESTONE",
            msg.sender,
            _jobId,
            _lockedAmount
        );
        
        MessagingFee memory fee = _quote(nojcEndpointId, payload, _options, false);
        require(msg.value >= fee.nativeFee, "Insufficient fee for cross-chain message");
        
        _lzSend(
            nojcEndpointId,
            payload,
            _options,
            MessagingFee(msg.value, 0),
            payable(msg.sender)
        );
        
        emit MilestoneLocked(_jobId, jobs[_jobId].currentMilestone, _lockedAmount);
        emit CrossChainMessageSent(_jobId, "LOCK_NEXT_MILESTONE", nojcEndpointId);
    }
    
    // Rating System
    function rate(
        uint256 _jobId, 
        address _userToRate, 
        uint256 _rating,
        bytes calldata _options
    ) external payable nonReentrant {
        require(jobs[_jobId].id != 0, "Job does not exist");
        require(!jobs[_jobId].isOpen, "Job must be started");
        require(_rating >= 1 && _rating <= 5, "Rating must be between 1 and 5");
        require(jobRatings[_jobId][_userToRate] == 0, "User already rated for this job");
        
        bool isAuthorized = false;
        
        // Check if caller is job giver rating the selected applicant
        if (msg.sender == jobs[_jobId].jobGiver && _userToRate == jobs[_jobId].selectedApplicant) {
            isAuthorized = true;
        }
        // Check if caller is selected applicant rating the job giver
        else if (msg.sender == jobs[_jobId].selectedApplicant && _userToRate == jobs[_jobId].jobGiver) {
            isAuthorized = true;
        }
        
        require(isAuthorized, "Not authorized to rate this user for this job");
        
        jobRatings[_jobId][_userToRate] = _rating;
        userRatings[_userToRate].push(_rating);
        
        // Send cross-chain message to NOJC
        bytes memory payload = abi.encode(
            "RATE_USER",
            msg.sender,
            _jobId,
            _userToRate,
            _rating
        );
        
        MessagingFee memory fee = _quote(nojcEndpointId, payload, _options, false);
        require(msg.value >= fee.nativeFee, "Insufficient fee for cross-chain message");
        
        _lzSend(
            nojcEndpointId,
            payload,
            _options,
            MessagingFee(msg.value, 0),
            payable(msg.sender)
        );
        
        emit UserRated(_jobId, msg.sender, _userToRate, _rating);
        emit CrossChainMessageSent(_jobId, "RATE_USER", nojcEndpointId);
    }
    
    function getRating(address _user) public view returns (uint256) {
        uint256[] memory ratings = userRatings[_user];
        if (ratings.length == 0) {
            return 0;
        }
        
        uint256 totalRating = 0;
        for (uint i = 0; i < ratings.length; i++) {
            totalRating += ratings[i];
        }
        
        return totalRating / ratings.length;
    }
    
    // Portfolio Management
    function addPortfolio(
        string memory _portfolioHash,
        bytes calldata _options
    ) external payable nonReentrant {
        require(hasProfile[msg.sender], "Profile does not exist");
        require(bytes(_portfolioHash).length > 0, "Portfolio hash cannot be empty");
        
        profiles[msg.sender].portfolioHashes.push(_portfolioHash);
        
        // Send cross-chain message to NOJC
        bytes memory payload = abi.encode(
            "ADD_PORTFOLIO",
            msg.sender,
            _portfolioHash
        );
        
        MessagingFee memory fee = _quote(nojcEndpointId, payload, _options, false);
        require(msg.value >= fee.nativeFee, "Insufficient fee for cross-chain message");
        
        _lzSend(
            nojcEndpointId,
            payload,
            _options,
            MessagingFee(msg.value, 0),
            payable(msg.sender)
        );
        
        emit PortfolioAdded(msg.sender, _portfolioHash);
        emit CrossChainMessageSent(0, "ADD_PORTFOLIO", nojcEndpointId);
    }
    
    // Quote functions for LayerZero fees
    function quoteCreateProfile(
        string memory _ipfsHash,
        address _referrerAddress,
        uint256 _rating,
        bytes calldata _options
    ) external view returns (MessagingFee memory) {
        bytes memory payload = abi.encode(
            "CREATE_PROFILE",
            msg.sender,
            _ipfsHash,
            _referrerAddress,
            _rating
        );
        return _quote(nojcEndpointId, payload, _options, false);
    }
    
    function quotePostJob(
        string memory _jobDetailHash,
        MilestonePayment[] memory _milestonePayments,
        bytes calldata _options
    ) external view returns (MessagingFee memory) {
        bytes memory payload = abi.encode(
            "POST_JOB",
            msg.sender,
            _jobDetailHash,
            _milestonePayments,
            0 // placeholder for totalAmount
        );
        return _quote(nojcEndpointId, payload, _options, false);
    }
    
    function quoteApplyToJob(
        uint256 _jobId,
        string memory _applicationHash,
        MilestonePayment[] memory _proposedMilestones,
        bytes calldata _options
    ) external view returns (MessagingFee memory) {
        bytes memory payload = abi.encode(
            "APPLY_TO_JOB",
            msg.sender,
            _jobId,
            _applicationHash,
            _proposedMilestones
        );
        return _quote(nojcEndpointId, payload, _options, false);
    }
    
    // Emergency functions
    function emergencyWithdraw(uint256 _jobId) external onlyOwner {
        require(jobs[_jobId].id != 0, "Job does not exist");
        require(jobs[_jobId].isOpen, "Can only withdraw from open jobs");
        
        uint256 remainingAmount = jobs[_jobId].totalEscrowed - jobs[_jobId].totalReleased;
        if (remainingAmount > 0) {
            usdtToken.safeTransfer(jobs[_jobId].jobGiver, remainingAmount);
            jobs[_jobId].totalReleased = jobs[_jobId].totalEscrowed;
        }
    }
    
    // Utility functions
    function getJobCount() external view returns (uint256) {
        return jobCounter;
    }
    
    function getJobApplicationCount(uint256 _jobId) external view returns (uint256) {
        return jobApplicationCounter[_jobId];
    }
    
    function isJobOpen(uint256 _jobId) external view returns (bool) {
        require(jobs[_jobId].id != 0, "Job does not exist");
        return jobs[_jobId].isOpen;
    }
    
    function getEscrowBalance(uint256 _jobId) external view returns (uint256 escrowed, uint256 released, uint256 remaining) {
        require(jobs[_jobId].id != 0, "Job does not exist");
        escrowed = jobs[_jobId].totalEscrowed;
        released = jobs[_jobId].totalReleased;
        remaining = escrowed - released;
    }
    
   // LayerZero receive function (empty since we only send to NOJC)
    function _lzReceive(
        Origin calldata,
        bytes32,
        bytes calldata,
        address,
        bytes calldata
    ) internal pure override {
        // LOJC only sends messages to NOJC, doesn't receive any
        revert("LOJC does not receive messages");
    }
    
    // Allow contract to receive Ether for LayerZero fees
    receive() external payable {}
}