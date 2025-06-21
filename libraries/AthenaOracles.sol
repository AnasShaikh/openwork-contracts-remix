// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title AthenaOracles
 * @dev Library for oracle-related functions in the Athena ecosystem
 */
library AthenaOracles {
    // Oracle data structure
    struct SkillOracle {
        string name;
        string description;
        address[] members;
        bool isActive;
        uint256 createdAt;
        uint256 memberCount;
        
        // Additional fields for governance
        uint256 minimumMembers;
        uint256 votingThreshold;
    }
    
    /**
     * @dev Check if an address is a member of the oracle
     * @param oracle The oracle to check
     * @param member The address to verify
     * @return True if the address is a member, false otherwise
     */
    function isMember(SkillOracle storage oracle, address member) internal view returns (bool) {
        for (uint256 i = 0; i < oracle.members.length; i++) {
            if (oracle.members[i] == member) {
                return true;
            }
        }
        return false;
    }
    
    /**
     * @dev Add a member to the oracle
     * @param oracle The oracle to modify
     * @param member The address to add
     * @return True if successful, false if the member was already part of the oracle
     */
    function addMember(SkillOracle storage oracle, address member) internal returns (bool) {
        if (isMember(oracle, member)) {
            return false;
        }
        
        oracle.members.push(member);
        oracle.memberCount++;
        return true;
    }
    
    /**
     * @dev Remove a member from the oracle
     * @param oracle The oracle to modify
     * @param member The address to remove
     * @return True if successful, false if the member was not part of the oracle
     */
    function removeMember(SkillOracle storage oracle, address member) internal returns (bool) {
        uint256 index = oracle.members.length;
        
        for (uint256 i = 0; i < oracle.members.length; i++) {
            if (oracle.members[i] == member) {
                index = i;
                break;
            }
        }
        
        if (index >= oracle.members.length) {
            return false;
        }
        
        // Move the last element to the position of the element to delete
        if (index < oracle.members.length - 1) {
            oracle.members[index] = oracle.members[oracle.members.length - 1];
        }
        
        // Remove the last element
        oracle.members.pop();
        oracle.memberCount--;
        
        return true;
    }
    
    /**
     * @dev Activate an oracle
     * @param oracle The oracle to activate
     */
    function activate(SkillOracle storage oracle) internal {
        oracle.isActive = true;
    }
    
    /**
     * @dev Deactivate an oracle
     * @param oracle The oracle to deactivate
     */
    function deactivate(SkillOracle storage oracle) internal {
        oracle.isActive = false;
    }
    
    /**
     * @dev Check if an oracle has enough members to function
     * @param oracle The oracle to check
     * @return True if the oracle has enough members, false otherwise
     */
    function hasEnoughMembers(SkillOracle storage oracle) internal view returns (bool) {
        return oracle.memberCount >= oracle.minimumMembers;
    }
    
    /**
     * @dev Get the number of votes needed to pass a proposal
     * @param oracle The oracle to check
     * @return The number of votes needed
     */
    function requiredVotes(SkillOracle storage oracle) internal view returns (uint256) {
        return (oracle.memberCount * oracle.votingThreshold) / 100;
    }
}