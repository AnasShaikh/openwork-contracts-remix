// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title IOpenWorkUserRegistry
 * @dev Interface for the OpenWork User Registry Contract
 */
interface IOpenWorkUserRegistry {
    /**
     * @dev Rating struct to standardize rating data
     */
    struct Rating {
        uint256 jobId;
        address rater;
        uint8 rating;
        uint256 timestamp;
    }
    
    /**
     * @dev PortfolioItem struct to standardize portfolio data
     */
    struct PortfolioItem {
        uint256 id;
        string title;
        string description;
        string contentHash;
        uint256 createdAt;
    }
    
    /**
     * @dev Check if a user exists
     * @param userAddress The address of the user
     * @return exists True if the user exists
     */
    function userExists(address userAddress) external view returns (bool exists);
    
    /**
     * @dev Create a user profile
     * @param name The name of the user
     * @param skills Array of user skills
     * @param profileHash IPFS hash containing extended profile data
     */
    function createUserProfile(
        string memory name,
        string[] memory skills,
        string memory profileHash
    ) external;
    
    /**
     * @dev Create a user profile - alias for createUserProfile
     * @param name The name of the user
     * @param skills Array of user skills
     * @param profileHash IPFS hash containing extended profile data
     */
    function createProfile(
        string memory name,
        string[] memory skills,
        string memory profileHash
    ) external;
    
    /**
     * @dev Update an existing user profile
     * @param name The updated name of the user
     * @param skills Updated array of user skills
     * @param profileHash Updated IPFS hash containing extended profile data
     */
    function updateUserProfile(
        string memory name,
        string[] memory skills,
        string memory profileHash
    ) external;
    
    /**
     * @dev Update an existing user profile - alias for updateUserProfile
     * @param name The updated name of the user
     * @param skills Updated array of user skills
     * @param profileHash Updated IPFS hash containing extended profile data
     */
    function updateProfile(
        string memory name,
        string[] memory skills,
        string memory profileHash
    ) external;
    
    /**
     * @dev Get user profile details
     * @param user The address of the user
     * @return userAddress User's address
     * @return name User's name
     * @return skills User's skills
     * @return profileHash IPFS hash containing extended profile data
     * @return reputation User's reputation
     * @return exists Whether the user exists
     */
    function getUserProfile(address user) external view returns (
        address userAddress,
        string memory name,
        string[] memory skills,
        string memory profileHash,
        uint256 reputation,
        bool exists
    );
    
    /**
     * @dev Get user profile details - alias for getUserProfile
     * @param userAddress The address of the user
     * @return name User's name
     * @return skills User's skills
     * @return profileHash IPFS hash containing extended profile data
     * @return isVerified Whether the user is verified
     * @return exists Whether the user exists
     */
    function getProfile(address userAddress) external view returns (
        string memory name,
        string[] memory skills,
        string memory profileHash,
        bool isVerified,
        bool exists
    );
    
    /**
     * @dev Rate a user (job giver or freelancer) after job completion
     * @param jobId The ID of the completed job
     * @param user The address of the user to rate
     * @param rating The rating (1-5)
     */
    function rate(uint256 jobId, address user, uint8 rating) external;
    
    /**
     * @dev Get the rating data for a user
     * @param user The address of the user
     * @return averageRating The average rating of the user
     * @return ratingCount The number of ratings for the user
     */
    function getRating(address user) external view returns (uint8 averageRating, uint256 ratingCount);
    
    /**
     * @dev Get a specific rating for a user
     * @param user The address of the user
     * @param index The index of the rating
     * @return jobId The ID of the job
     * @return rater The address of the rater
     * @return rating The rating value
     * @return timestamp The time the rating was given
     */
    function getRatingDetails(address user, uint256 index) external view returns (
        uint256 jobId,
        address rater,
        uint8 rating,
        uint256 timestamp
    );
    
    /**
     * @dev Add a portfolio item to a user's profile
     * @param title The title of the portfolio item
     * @param description The description of the portfolio item
     * @param contentHash IPFS hash pointing to portfolio content
     * @return itemId The ID of the created portfolio item
     */
    function addPortfolio(
        string memory title,
        string memory description,
        string memory contentHash
    ) external returns (uint256 itemId);
    
    /**
     * @dev Get the number of portfolio items for a user
     * @param user The address of the user
     * @return count The number of portfolio items
     */
    function getPortfolioCount(address user) external view returns (uint256 count);
    
    /**
     * @dev Get portfolio item details
     * @param user The address of the user
     * @param itemId The ID of the portfolio item
     * @return title The title of the portfolio item
     * @return description The description of the portfolio item
     * @return contentHash IPFS hash pointing to portfolio content
     * @return createdAt The creation timestamp of the portfolio item
     */
    function getPortfolioItem(
        address user,
        uint256 itemId
    ) external view returns (
        string memory title,
        string memory description,
        string memory contentHash,
        uint256 createdAt
    );
    
    /**
     * @dev Increment the reputation of a user
     * @param user The address of the user
     * @param amount The amount to increment
     * @return newReputation The new reputation value
     */
    function incrementReputation(address user, uint256 amount) external returns (uint256 newReputation);
    
    /**
     * @dev Set the job market contract address
     * @param jobMarketAddress The address of the job market contract
     */
    function setJobMarketContract(address jobMarketAddress) external;
}