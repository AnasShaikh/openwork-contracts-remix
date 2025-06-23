// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { OApp, MessagingFee, Origin } from "@layerzerolabs/oapp-evm/contracts/oapp/OApp.sol";
import { MessagingReceipt } from "@layerzerolabs/oapp-evm/contracts/oapp/OAppSender.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

interface IJobContract {
    function getJob(uint256 jobId) external view returns (
        uint256 id,
        address jobGiver,
        address[] memory applicants,
        string memory jobDetailHash,
        bool isOpen,
        string[] memory workSubmissions,
        uint256 totalPaid,
        uint256 currentLockedAmount,
        uint256 currentMilestone,
        address selectedApplicant,
        uint256 selectedApplicationId
    );
    
    function getProfile(address user) external view returns (
        address userAddress,
        string memory ipfsHash,
        address referrerAddress,
        uint256 rating,
        string[] memory portfolioHashes
    );
}

contract RewardsTrackingContract is OApp, ReentrancyGuard {
    IJobContract public jobContract;
    
    // LayerZero configuration
    uint32 public daoChainEid; // DAO contract endpoint ID
    bytes public lzOptions; // LayerZero options for gas
    
    // Reward bands structure
    struct RewardBand {
        uint256 minAmount;
        uint256 maxAmount;
        uint256 owPerDollar;
    }
    
    // User cumulative tracking
    mapping(address => uint256) public userCumulativeEarnings;
    mapping(address => uint256) public userTotalOWTokens;
    
    // Job tracking
    mapping(uint256 => bool) public jobProcessed;
    mapping(uint256 => uint256) public jobTotalPaid;
    
    // Reward bands array
    RewardBand[] public rewardBands;
    
    // Events
    event RewardsUpdated(
        uint256 indexed jobId, 
        uint256 paidAmountUSDT, 
        address indexed jobGiver, 
        address indexed jobTaker,
        uint256 jobGiverTokens,
        uint256 jobTakerTokens
    );
    
    event TokensEarned(
        address indexed user, 
        uint256 tokensEarned, 
        uint256 newCumulativeEarnings,
        uint256 newTotalTokens
    );

    // NEW EVENT: Cross-chain earner update sent
    event EarnerUpdateSent(address indexed earner, uint256 balance, uint256 governanceActions);
    
    constructor(
        address _endpoint,
        address _owner,
        uint32 _daoChainEid
    ) OApp(_endpoint, _owner) Ownable(_owner) {
        daoChainEid = _daoChainEid;
        // Set default LayerZero options (can be updated by owner)
        lzOptions = hex"00030100110100000000000000000000000000030d40";
        _initializeRewardBands();
    }
    
    // NEW: Set DAO chain endpoint ID
    function setDaoChainEid(uint32 _daoChainEid) external onlyOwner {
        daoChainEid = _daoChainEid;
    }
    
    // NEW: Set LayerZero options
    function setLzOptions(bytes calldata _options) external onlyOwner {
        lzOptions = _options;
    }
    
    function setJobContract(address _jobContract) external onlyOwner {
        jobContract = IJobContract(_jobContract);
    }
    
    function _initializeRewardBands() private {
        // Initialize all reward bands based on the provided table
        rewardBands.push(RewardBand(0, 500 * 1e6, 100000 * 1e18)); // $0 - $500: 100,000 OW per $
        rewardBands.push(RewardBand(500 * 1e6, 1000 * 1e6, 50000 * 1e18)); // $500 - $1,000: 50,000 OW per $
        rewardBands.push(RewardBand(1000 * 1e6, 2000 * 1e6, 25000 * 1e18)); // $1,000 - $2,000: 25,000 OW per $
        rewardBands.push(RewardBand(2000 * 1e6, 4000 * 1e6, 12500 * 1e18)); // $2,000 - $4,000: 12,500 OW per $
        rewardBands.push(RewardBand(4000 * 1e6, 8000 * 1e6, 6250 * 1e18)); // $4,000 - $8,000: 6,250 OW per $
        rewardBands.push(RewardBand(8000 * 1e6, 16000 * 1e6, 3125 * 1e18)); // $8,000 - $16,000: 3,125 OW per $
        rewardBands.push(RewardBand(16000 * 1e6, 32000 * 1e6, 1562 * 1e18)); // $16,000 - $32,000: 1,562 OW per $
        rewardBands.push(RewardBand(32000 * 1e6, 64000 * 1e6, 781 * 1e18)); // $32,000 - $64,000: 781 OW per $
        rewardBands.push(RewardBand(64000 * 1e6, 128000 * 1e6, 391 * 1e18)); // $64,000 - $128,000: 391 OW per $
        rewardBands.push(RewardBand(128000 * 1e6, 256000 * 1e6, 195 * 1e18)); // $128,000 - $256,000: 195 OW per $
        rewardBands.push(RewardBand(256000 * 1e6, 512000 * 1e6, 98 * 1e18)); // $256,000 - $512,000: 98 OW per $
        rewardBands.push(RewardBand(512000 * 1e6, 1024000 * 1e6, 49 * 1e18)); // $512,000 - $1.024M: 49 OW per $
        rewardBands.push(RewardBand(1024000 * 1e6, 2048000 * 1e6, 24 * 1e18)); // $1.024M - $2.048M: 24 OW per $
        rewardBands.push(RewardBand(2048000 * 1e6, 4096000 * 1e6, 12 * 1e18)); // $2.048M - $4.096M: 12 OW per $
        rewardBands.push(RewardBand(4096000 * 1e6, 8192000 * 1e6, 6 * 1e18)); // $4.096M - $8.192M: 6 OW per $
        rewardBands.push(RewardBand(8192000 * 1e6, 16384000 * 1e6, 3 * 1e18)); // $8.192M - $16.384M: 3 OW per $
        rewardBands.push(RewardBand(16384000 * 1e6, 32768000 * 1e6, 15 * 1e17)); // $16.384M - $32.768M: 1.5 OW per $
        rewardBands.push(RewardBand(32768000 * 1e6, 65536000 * 1e6, 75 * 1e16)); // $32.768M - $65.536M: 0.75 OW per $
        rewardBands.push(RewardBand(65536000 * 1e6, 131072000 * 1e6, 38 * 1e16)); // $65.536M - $131.072M: 0.38 OW per $
        rewardBands.push(RewardBand(131072000 * 1e6, type(uint256).max, 19 * 1e16)); // $131.072M+: 0.19 OW per $
    }
    
    // UPDATED: Modified updateRewards function to send cross-chain messages
    function updateRewards(uint256 jobId, uint256 paidAmountUSDT) external payable nonReentrant {
        require(address(jobContract) != address(0), "Job contract not set");
        require(msg.sender == address(jobContract), "Only job contract can call this");
        require(paidAmountUSDT > 0, "Paid amount must be greater than 0");
        
        // Get job details
        (
            ,
            address jobGiver,
            ,
            ,
            ,
            ,
            ,
            ,
            ,
            address selectedApplicant,
        ) = jobContract.getJob(jobId);
        
        require(jobGiver != address(0), "Invalid job giver");
        require(selectedApplicant != address(0), "No selected applicant");
        
        // Update job total paid tracking
        jobTotalPaid[jobId] += paidAmountUSDT;
        
        // Get referrers
        address jobGiverReferrer = getReferrer(jobGiver);
        address jobTakerReferrer = getReferrer(selectedApplicant);
        
        // Calculate and update rewards for job giver
        uint256 jobGiverTokens = calculateAndUpdateTokens(jobGiver, paidAmountUSDT);
        
        // Calculate and update rewards for job taker (selected applicant)
        uint256 jobTakerTokens = calculateAndUpdateTokens(selectedApplicant, paidAmountUSDT);
        
        // Update rewards for referrers if they exist
        if (jobGiverReferrer != address(0) && jobGiverReferrer != jobGiver) {
            calculateAndUpdateTokens(jobGiverReferrer, paidAmountUSDT / 10); // 10% referral bonus
        }
        
        if (jobTakerReferrer != address(0) && jobTakerReferrer != selectedApplicant && jobTakerReferrer != jobGiverReferrer) {
            calculateAndUpdateTokens(jobTakerReferrer, paidAmountUSDT / 10); // 10% referral bonus
        }

        // NEW: Send cross-chain updates to DAO contract
        _sendEarnerUpdate(jobGiver, userTotalOWTokens[jobGiver]);
        _sendEarnerUpdate(selectedApplicant, userTotalOWTokens[selectedApplicant]);
        
        emit RewardsUpdated(jobId, paidAmountUSDT, jobGiver, selectedApplicant, jobGiverTokens, jobTakerTokens);
    }
    
    // NEW: Internal function to send earner updates cross-chain
    function _sendEarnerUpdate(address earner, uint256 balance) internal {
        if (daoChainEid == 0) return; // Skip if DAO chain not configured
        
        // Simple governance action count (can be enhanced based on your logic)
        uint256 governanceActions = balance > 0 ? 1 : 0;
        
        // Encode payload for DAO contract
        bytes memory payload = abi.encode(earner, balance, governanceActions);
        
        // Calculate fee required
        MessagingFee memory fee = _quote(daoChainEid, payload, lzOptions, false);
        
        // Send cross-chain message if enough ETH provided
        if (address(this).balance >= fee.nativeFee) {
            _lzSend(
                daoChainEid,
                payload,
                lzOptions,
                MessagingFee(fee.nativeFee, 0),
                payable(owner())
            );
            
            emit EarnerUpdateSent(earner, balance, governanceActions);
        }
    }
    
    // NEW: Manual function to send earner update (with fee payment)
    function sendEarnerUpdate(address earner) external payable onlyOwner {
        uint256 balance = userTotalOWTokens[earner];
        uint256 governanceActions = balance > 0 ? 1 : 0;
        
        bytes memory payload = abi.encode(earner, balance, governanceActions);
        MessagingFee memory fee = _quote(daoChainEid, payload, lzOptions, false);
        require(msg.value >= fee.nativeFee, "Insufficient fee");
        
        _lzSend(
            daoChainEid,
            payload,
            lzOptions,
            MessagingFee(msg.value, 0),
            payable(msg.sender)
        );
        
        emit EarnerUpdateSent(earner, balance, governanceActions);
    }
    
    // NEW: Quote fee for sending earner update
    function quoteSendEarnerUpdate(address earner) external view returns (MessagingFee memory) {
        uint256 balance = userTotalOWTokens[earner];
        uint256 governanceActions = balance > 0 ? 1 : 0;
        bytes memory payload = abi.encode(earner, balance, governanceActions);
        return _quote(daoChainEid, payload, lzOptions, false);
    }
    
    // NEW: LayerZero receive handler (currently empty as this contract only sends)
    function _lzReceive(
        Origin calldata,
        bytes32,
        bytes calldata,
        address,
        bytes calldata
    ) internal override {}
    
    // NEW: Allow contract to receive ETH for LayerZero fees
    receive() external payable {}
    
    // [Rest of the existing functions remain unchanged...]
    
    function calculateAndUpdateTokens(address user, uint256 amountUSDT) private returns (uint256) {
        uint256 currentCumulative = userCumulativeEarnings[user];
        uint256 newCumulative = currentCumulative + amountUSDT;
        
        // Calculate tokens based on progressive bands
        uint256 tokensToAward = calculateTokensForRange(currentCumulative, newCumulative);
        
        // Update user's cumulative earnings and total tokens
        userCumulativeEarnings[user] = newCumulative;
        userTotalOWTokens[user] += tokensToAward;
        
        emit TokensEarned(user, tokensToAward, newCumulative, userTotalOWTokens[user]);
        
        return tokensToAward;
    }
    
    function calculateTokensForRange(uint256 fromAmount, uint256 toAmount) public view returns (uint256) {
        if (fromAmount >= toAmount) {
            return 0;
        }
        
        uint256 totalTokens = 0;
        uint256 currentAmount = fromAmount;
        
        for (uint256 i = 0; i < rewardBands.length && currentAmount < toAmount; i++) {
            RewardBand memory band = rewardBands[i];
            
            // Skip bands that are entirely below our starting point
            if (band.maxAmount <= currentAmount) {
                continue;
            }
            
            // Calculate the overlap with this band
            uint256 bandStart = currentAmount > band.minAmount ? currentAmount : band.minAmount;
            uint256 bandEnd = toAmount < band.maxAmount ? toAmount : band.maxAmount;
            
            if (bandStart < bandEnd) {
                uint256 amountInBand = bandEnd - bandStart;
                uint256 tokensInBand = (amountInBand * band.owPerDollar) / 1e6; // Convert USDT (6 decimals) to tokens
                totalTokens += tokensInBand;
                currentAmount = bandEnd;
            }
        }
        
        return totalTokens;
    }
    
    function getReferrer(address user) public view returns (address) {
        if (address(jobContract) == address(0)) {
            return address(0);
        }
        
        try jobContract.getProfile(user) returns (
            address,
            string memory,
            address referrerAddress,
            uint256,
            string[] memory
        ) {
            return referrerAddress;
        } catch {
            return address(0);
        }
    }
    
    // View functions
    function getUserCumulativeEarnings(address user) external view returns (uint256) {
        return userCumulativeEarnings[user];
    }
    
    function getUserTotalOWTokens(address user) external view returns (uint256) {
        return userTotalOWTokens[user];
    }
    
    function getJobTotalPaid(uint256 jobId) external view returns (uint256) {
        return jobTotalPaid[jobId];
    }
    
    function getRewardBandsCount() external view returns (uint256) {
        return rewardBands.length;
    }
    
    function getRewardBand(uint256 index) external view returns (uint256 minAmount, uint256 maxAmount, uint256 owPerDollar) {
        require(index < rewardBands.length, "Invalid band index");
        RewardBand memory band = rewardBands[index];
        return (band.minAmount, band.maxAmount, band.owPerDollar);
    }
    
    // Calculate tokens for a specific amount without updating state
    function calculateTokensForAmount(address user, uint256 additionalAmount) external view returns (uint256) {
        uint256 currentCumulative = userCumulativeEarnings[user];
        uint256 newCumulative = currentCumulative + additionalAmount;
        return calculateTokensForRange(currentCumulative, newCumulative);
    }
    
    // Emergency functions
    function updateUserCumulativeEarnings(address user, uint256 newAmount) external onlyOwner {
        userCumulativeEarnings[user] = newAmount;
    }
    
    function updateUserTotalOWTokens(address user, uint256 newAmount) external onlyOwner {
        userTotalOWTokens[user] = newAmount;
    }
}