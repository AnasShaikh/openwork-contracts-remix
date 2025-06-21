// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IOpenWorkPriceOracle {
    /**
     * @dev Get the price of OpenWork token in ETH
     * @return price Price of 1 OpenWork token in ETH (scaled by 1e18)
     */
    function getOpenWorkPriceInETH() external view returns (uint256 price);
    
    /**
     * @dev Get the price of ETH in OpenWork tokens
     * @return price Price of 1 ETH in OpenWork tokens (scaled by 1e18)
     */
    function getETHPriceInOpenWork() external view returns (uint256 price);
    
    /**
     * @dev Convert an ETH amount to its equivalent in OpenWork tokens
     * @param ethAmount Amount of ETH to convert
     * @return openWorkAmount Equivalent amount in OpenWork tokens
     */
    function convertETHToOpenWork(uint256 ethAmount) external view returns (uint256 openWorkAmount);
    
    /**
     * @dev Convert an OpenWork amount to its equivalent in ETH
     * @param openWorkAmount Amount of OpenWork tokens to convert
     * @return ethAmount Equivalent amount in ETH
     */
    function convertOpenWorkToETH(uint256 openWorkAmount) external view returns (uint256 ethAmount);
}