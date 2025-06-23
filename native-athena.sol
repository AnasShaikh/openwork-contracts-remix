// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SkillOracle {
    address public daoContract;
    
    struct Oracle {
        string name;
        address[] members;
        string shortDescription;
        string hashOfDetails;
        uint256 stakeAmount;
        address[] skillVerifiedAddresses;
    }
    
    struct SkillVerificationApplication {
        address applicant;
        string applicationHash;
        uint256 feeAmount;
        string targetOracleName;
    }
    
    struct Dispute {
        uint256 jobID;
        uint256 disputedAmount;
        string hash;
        address disputeRaiserAddress;
        uint256 votesFor;
        uint256 votesAgainst;
        bool result;
        bool isVotingActive;
        uint256 timeStamp;
        uint256 fees;
    }
    
    mapping(string => Oracle) public oracles;
    mapping(string => mapping(address => uint256)) public skillVerificationDates;
    mapping(uint256 => SkillVerificationApplication) public skillApplications;
    mapping(uint256 => Dispute) public disputes;
    uint256 public applicationCounter;
    uint256 public disputeCounter;
    uint256 public minOracleMembers = 3;
    
    modifier onlyDAO() {
        require(msg.sender == daoContract, "Only DAO can call this function");
        _;
    }
    
    constructor(address _daoContract) {
        daoContract = _daoContract;
    }
    
    function addOrUpdateOracle(
        string[] memory _names,
        address[][] memory _members,
        string[] memory _shortDescriptions,
        string[] memory _hashOfDetails,
        uint256[] memory _stakeAmounts,
        address[][] memory _skillVerifiedAddresses
    ) external onlyDAO {
        require(_names.length == _members.length && 
                _names.length == _shortDescriptions.length &&
                _names.length == _hashOfDetails.length &&
                _names.length == _stakeAmounts.length &&
                _names.length == _skillVerifiedAddresses.length, 
                "Array lengths must match");
        
        for (uint256 i = 0; i < _names.length; i++) {
            oracles[_names[i]] = Oracle({
                name: _names[i],
                members: _members[i],
                shortDescription: _shortDescriptions[i],
                hashOfDetails: _hashOfDetails[i],
                stakeAmount: _stakeAmounts[i],
                skillVerifiedAddresses: _skillVerifiedAddresses[i]
            });
        }
    }
    
    function approveSkillVerification(uint256 _applicationId) external onlyDAO {
        require(_applicationId < applicationCounter, "Invalid application ID");
        
        SkillVerificationApplication memory application = skillApplications[_applicationId];
        require(bytes(oracles[application.targetOracleName].name).length > 0, "Oracle not found");
        
        oracles[application.targetOracleName].skillVerifiedAddresses.push(application.applicant);
        skillVerificationDates[application.targetOracleName][application.applicant] = block.timestamp;
    }
    
    function raiseDispute(
        uint256 _jobId,
        string memory _disputeHash,
        string memory _oracleName,
        uint256 _fee
    ) external {
        // Check if oracle is active (has minimum required members)
        require(oracles[_oracleName].members.length >= minOracleMembers, "Oracle not active");
        
        // TODO: Implement getJobDetails() - get job details from another contract
        
        // TODO: Implement check if caller is involved in the job
        
        // Create new dispute
        disputes[disputeCounter] = Dispute({
            jobID: _jobId,
            disputedAmount: _fee,
            hash: _disputeHash,
            disputeRaiserAddress: msg.sender,
            votesFor: 0,
            votesAgainst: 0,
            result: false,
            isVotingActive: true,
            timeStamp: block.timestamp,
            fees: _fee
        });
        disputeCounter++;
    }
    
    function updateMinOracleMembers(uint256 _newMinMembers) external onlyDAO {
        minOracleMembers = _newMinMembers;
    }
    
    function removeMemberFromOracle(string memory _oracleName, address _memberToRemove) external onlyDAO {
        require(bytes(oracles[_oracleName].name).length > 0, "Oracle not found");
        
        address[] storage members = oracles[_oracleName].members;
        for (uint256 i = 0; i < members.length; i++) {
            if (members[i] == _memberToRemove) {
                members[i] = members[members.length - 1];
                members.pop();
                break;
            }
        }
    }
    
    function removeOracle(string[] memory _oracleNames) external onlyDAO {
        for (uint256 i = 0; i < _oracleNames.length; i++) {
            delete oracles[_oracleNames[i]];
        }
    }
    
    function submitSkillVerification(
        string memory _applicationHash,
        uint256 _feeAmount,
        string memory _targetOracleName
    ) external {
        skillApplications[applicationCounter] = SkillVerificationApplication({
            applicant: msg.sender,
            applicationHash: _applicationHash,
            feeAmount: _feeAmount,
            targetOracleName: _targetOracleName
        });
        applicationCounter++;
    }
}