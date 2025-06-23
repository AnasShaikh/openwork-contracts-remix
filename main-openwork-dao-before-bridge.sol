// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/governance/Governor.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorSettings.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorCountingSimple.sol";
import "@openzeppelin/contracts/governance/IGovernor.sol";

interface IERC20 {
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function transfer(address to, uint256 amount) external returns (bool);
}

contract MainOpenworkDAO is Governor, GovernorSettings, GovernorCountingSimple {
    IERC20 public openworkToken;
    uint256 public constant MIN_STAKE = 100 * 10**18; // 100 tokens (assuming 18 decimals)
    
    // Governance parameters (updatable)
    uint256 public proposalStakeThreshold = 100 * 10**18; // 100 tokens to create proposal
    uint256 public votingStakeThreshold = 50 * 10**18;    // 50 tokens to vote
    uint256 public unstakeDelay = 24 hours; // Default 24 hour delay
    
    struct Stake {
        uint256 amount;
        uint256 unlockTime;
        uint256 durationMinutes;
    }

    struct Earner {
        address earnerAddress;
        uint256 balance;
        uint256 total_governance_actions;
    }

    mapping(address => Earner) public earners;
    mapping(address => Stake) public stakes;
    mapping(address => uint256) public unstakeRequestTime;
    mapping(address => address) public delegates;
    mapping(address => uint256) public delegatedVotingPower;
    mapping(address => bool) public isStaker;
    
    // Helper functions for easier testing
    uint256[] public proposalIds;
    address[] public allStakers;
    
    // Events
    event StakeRemoved(address indexed staker, uint256 amount);
    event UnstakeRequested(address indexed staker, uint256 requestTime, uint256 availableTime);
    event EarnerUpdated(address indexed earner, uint256 newBalance, uint256 totalGovernanceActions);
    event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);
    
    constructor(address _openworkToken) 
        Governor("OpenWorkDAO")
        GovernorSettings(
            1 minutes,  // voting delay
            5 minutes,  // voting period  
            100 * 10**18 // proposal threshold
        )
    {
        openworkToken = IERC20(_openworkToken);
    }
    
    function stake(uint256 amount, uint256 durationMinutes) external {
        require(amount >= MIN_STAKE, "Minimum stake is 100 tokens");
        require(durationMinutes >= 1 && durationMinutes <= 3, "Duration must be 1-3 minutes");
        require(stakes[msg.sender].amount == 0, "Already staking");
        
        openworkToken.transferFrom(msg.sender, address(this), amount);
        
        stakes[msg.sender] = Stake({
            amount: amount,
            unlockTime: block.timestamp + (durationMinutes * 60),
            durationMinutes: durationMinutes
        });

            if (!isStaker[msg.sender]) {
        allStakers.push(msg.sender);
        isStaker[msg.sender] = true;
        }
    }
    
    function unstake() external {
        Stake memory userStake = stakes[msg.sender];
        require(userStake.amount > 0, "No stake found");
        require(block.timestamp >= userStake.unlockTime, "Stake still locked");
        
        if (unstakeRequestTime[msg.sender] == 0) {
            // First call - start the delay
            unstakeRequestTime[msg.sender] = block.timestamp;
            emit UnstakeRequested(msg.sender, block.timestamp, block.timestamp + unstakeDelay);
        } else {
            // Second call - check delay and execute
            require(block.timestamp >= unstakeRequestTime[msg.sender] + unstakeDelay, "Unstake delay not met");

            if (stakes[msg.sender].amount == 0) {
            isStaker[msg.sender] = false;
        }
            
            delete stakes[msg.sender];
            delete unstakeRequestTime[msg.sender];
            openworkToken.transfer(msg.sender, userStake.amount);
        }
    }
    
    // Remove specified amount from a staker's stake
    function removeStake(address staker, uint256 removeAmount) external onlyGovernance {
        require(stakes[staker].amount > 0, "No stake found");
        require(removeAmount <= stakes[staker].amount, "Remove amount exceeds stake");
        
        stakes[staker].amount -= removeAmount;
        
        // If remaining stake is below minimum, remove the stake entirely
        if (stakes[staker].amount < MIN_STAKE) {
            delete stakes[staker];
        }
        
        // Tokens stay in the contract
        emit StakeRemoved(staker, removeAmount);
    }

    function addOrUpdateEarner(address earnerAddress, uint256 balance, uint256 governanceActions) external onlyGovernance {
    require(earnerAddress != address(0), "Invalid earner address");
    
    earners[earnerAddress] = Earner({
        earnerAddress: earnerAddress,
        balance: balance,
        total_governance_actions: governanceActions
    });
    
    emit EarnerUpdated(earnerAddress, balance, governanceActions);
    }
    
    // Delegate voting power to another address
    function delegate(address delegatee) external {
        address currentDelegate = delegates[msg.sender];
        require(delegatee != currentDelegate, "Already delegated to this address");
        require(stakes[msg.sender].amount > 0, "No stake to delegate");
        
        uint256 delegatorPower = stakes[msg.sender].amount * stakes[msg.sender].durationMinutes;
        
        // Remove power from current delegate (if any)
        if (currentDelegate != address(0)) {
            delegatedVotingPower[currentDelegate] -= delegatorPower;
        }
        
        // Add power to new delegate
        if (delegatee != address(0)) {
            delegatedVotingPower[delegatee] += delegatorPower;
        }
        
        delegates[msg.sender] = delegatee;
        emit DelegateChanged(msg.sender, currentDelegate, delegatee);
    }
    
    // Required IERC6372 implementations
    function clock() public view override returns (uint48) {
        return uint48(block.timestamp);
    }
    
    function CLOCK_MODE() public pure override returns (string memory) {
        return "mode=timestamp";
    }

        // Get all stakers
    function getAllStakers() external view returns (address[] memory) {
        return allStakers;
    }

    // Get staker info
    function getStakerInfo(address staker) external view returns (uint256 amount, uint256 unlockTime, uint256 durationMinutes, bool hasStake) {
        Stake memory userStake = stakes[staker];
        return (userStake.amount, userStake.unlockTime, userStake.durationMinutes, userStake.amount > 0);
    }
    
    function getEarner(address earnerAddress) external view returns (address, uint256, uint256) {
    Earner memory earner = earners[earnerAddress];
    return (earner.earnerAddress, earner.balance, earner.total_governance_actions);
    }
    
    // Governor required functions
    function _getVotes(address account, uint256 /* timepoint */, bytes memory) internal view override returns (uint256) {
        // Own voting power
        Stake memory userStake = stakes[account];
        uint256 ownPower = 0;
        if (userStake.amount > 0) {
            ownPower = userStake.amount * userStake.durationMinutes;
        }
        
        // Add delegated voting power
        uint256 totalPower = ownPower + delegatedVotingPower[account];
        
        return totalPower;
    }
    
    function hasVoted(uint256 proposalId, address account) public view override(IGovernor, GovernorCountingSimple) returns (bool) {
        return super.hasVoted(proposalId, account);
    }
    
    function _castVote(uint256 proposalId, address account, uint8 support, string memory reason, bytes memory params)
        internal override returns (uint256) {
        require(stakes[account].amount >= votingStakeThreshold, "Insufficient stake to vote");
        return super._castVote(proposalId, account, support, reason, params);
    }
    
    function propose(address[] memory targets, uint256[] memory values, bytes[] memory calldatas, string memory description)
        public override returns (uint256) {
        require(stakes[msg.sender].amount >= proposalStakeThreshold, "Insufficient stake to propose");
        uint256 proposalId = super.propose(targets, values, calldatas, description);
        proposalIds.push(proposalId);
        return proposalId;
    }
    
    function quorum(uint256) public pure override returns (uint256) {
        // Lower quorum for testing - 50 tokens total voting power needed
        return 50 * 10**18;
    }
    
    // Required overrides for multiple inheritance
    function votingDelay() public view override(Governor, GovernorSettings) returns (uint256) {
        return super.votingDelay();
    }
    
    function votingPeriod() public view override(Governor, GovernorSettings) returns (uint256) {
        return super.votingPeriod();
    }
    
    function proposalThreshold() public view override(Governor, GovernorSettings) returns (uint256) {
        return super.proposalThreshold();
    }
    
    function getActiveProposalIds() external view returns (uint256[] memory activeIds, ProposalState[] memory states) {
        uint256 activeCount = 0;
        
        // First pass: count active proposals
        for (uint256 i = 0; i < proposalIds.length; i++) {
            if (state(proposalIds[i]) == ProposalState.Active) {
                activeCount++;
            }
        }
        
        // Second pass: collect active proposals
        activeIds = new uint256[](activeCount);
        states = new ProposalState[](activeCount);
        uint256 index = 0;
        
        for (uint256 i = 0; i < proposalIds.length; i++) {
            ProposalState currentState = state(proposalIds[i]);
            if (currentState == ProposalState.Active) {
                activeIds[index] = proposalIds[i];
                states[index] = currentState;
                index++;
            }
        }
    }
    
    function getAllProposalIds() external view returns (uint256[] memory ids, ProposalState[] memory states) {
        ids = new uint256[](proposalIds.length);
        states = new ProposalState[](proposalIds.length);
        
        for (uint256 i = 0; i < proposalIds.length; i++) {
            ids[i] = proposalIds[i];
            states[i] = state(proposalIds[i]);
        }
    }
    
    function getProposalCount() external view returns (uint256) {
        return proposalIds.length;
    }
    
    // Admin functions to update parameters
    function updateProposalStakeThreshold(uint256 newThreshold) external onlyGovernance {
        proposalStakeThreshold = newThreshold;
    }
    
    function updateVotingStakeThreshold(uint256 newThreshold) external onlyGovernance {
        votingStakeThreshold = newThreshold;
    }
    
    function updateUnstakeDelay(uint256 newDelay) external onlyGovernance {
        unstakeDelay = newDelay;
    }
    
    // View function to check when unstake will be available
    function getUnstakeAvailableTime(address staker) external view returns (uint256) {
        if (unstakeRequestTime[staker] == 0) return 0;
        return unstakeRequestTime[staker] + unstakeDelay;
    }
    
    // View function to get total voting power including delegations
    function getVotingPower(address account) external view returns (uint256 own, uint256 delegated, uint256 total) {
        Stake memory userStake = stakes[account];
        own = userStake.amount > 0 ? userStake.amount * userStake.durationMinutes : 0;
        delegated = delegatedVotingPower[account];
        total = own + delegated;
    }
    
    function updateQuorum(uint256 newQuorum) external onlyGovernance {
        // This would need to be implemented with a state variable instead of pure function
        // For now, governance can update via other proposals
    }
}