// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title IPriceOracle
 * @dev Interface for price oracle functionality
 */
interface IPriceOracle {
    /**
     * @dev Get the price of ETH in USD
     * @return The price of 1 ETH in USD with 18 decimals
     */
    function getETHUSDPrice() external view returns (uint256);
    
    /**
     * @dev Get the price of token in USD
     * @return The price of 1 token in USD with 18 decimals
     */
    function getTokenUSDPrice() external view returns (uint256);
    
    /**
     * @dev Convert an ETH amount to its USD value
     * @param ethAmount Amount of ETH (in wei)
     * @return The USD value with 18 decimals
     */
    function convertETHToUSD(uint256 ethAmount) external view returns (uint256);
    
    /**
     * @dev Convert an ETH amount to its USD value (alias for convertETHToUSD)
     * @param amountETH Amount of ETH (in wei)
     * @return The USD value with 18 decimals
     */
    function getETHToUSDPrice(uint256 amountETH) external view returns (uint256);
    
    /**
     * @dev Convert a USD amount to the equivalent token amount
     * @param usdAmount Amount in USD with 18 decimals
     * @return The token amount
     */
    function getUSDToTokenPrice(uint256 usdAmount) external view returns (uint256);
}