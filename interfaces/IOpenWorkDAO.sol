// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title IOpenWorkDAO
 * @dev Interface for OpenWorkDAO contract
 */
interface IOpenWorkDAO {
    // Team tokens struct definition
    struct TeamTokens {
        uint256 oneYear;
        uint256 twoYear; 
        uint256 threeYear;
        uint256 oneYearClaimDate;
        uint256 twoYearClaimDate;
        uint256 threeYearClaimDate;
        uint256 claimedTokens;
    }
    
    // Original contract struct definition
    struct OriginalContract {
        address contractAddress;
        bool isActive;
        string contractName;
    }
    
    // Events
    event ContractUpgraded(uint64 chainId, uint8 contractType, address newImplementation);
    
    function recordGovernanceAction(address member) external;
    
    /**
     * @dev Get the total number of governance actions performed by a member
     * @param member Address of the member
     * @return The total number of governance actions
     */
    function getGovernanceActions(address member) external view returns (uint256);
    function getTeamTokens(address member) external view returns (uint256, uint256, uint256);
    function requestConfiscation(address member) external returns (bool);
    function executeConfiscation(address member) external returns (bool);
    function canVoteInGovernance(address member) external view returns (bool);
    function getVotingPower(address member) external view returns (uint256);
    
    // Original contract management functions
    function registerOriginalContract(
        uint64 chainId, 
        uint8 contractType, 
        address contractAddress, 
        string memory contractName
    ) external returns (bool);
    
    function getOriginalContract(uint64 chainId, uint8 contractType) 
        external view returns (address, bool, string memory);
        
    function setOriginalContractStatus(
        uint64 chainId, 
        uint8 contractType, 
        bool isActive
    ) external;
    
    // Contract upgrade functions
    function upgradeContract(
        uint64 chainId,
        uint8 contractType,
        address newImplementation
    ) external returns (bytes32);
    
    function upgradeLocalContract(
        uint8 contractType,
        address newImplementation
    ) external returns (bool);
}