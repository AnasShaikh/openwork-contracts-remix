// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ContractRegistry {
    address public mainOpenworkDAO;
    address public nativeDAO;
    address public nativeAthena;
    address public athenaClientContract;
    address public nativeOpenWorkContract;
    address public localOpenWorkContract;
    address public rewardsTracking;
    address public payoutContracts;
    address public mainTokenContract;

    modifier onlyMainDAO() {
        require(msg.sender == mainOpenworkDAO, "Only Main DAO can set addresses");
        _;
    }

    constructor(address _mainOpenworkDAO) {
        mainOpenworkDAO = _mainOpenworkDAO;
    }

    function setNativeDAO(address _addr) external onlyMainDAO {
        nativeDAO = _addr;
    }

    function setNativeAthena(address _addr) external onlyMainDAO {
        nativeAthena = _addr;
    }

    function setAthenaClientContract(address _addr) external onlyMainDAO {
        athenaClientContract = _addr;
    }

    function setNativeOpenWorkContract(address _addr) external onlyMainDAO {
        nativeOpenWorkContract = _addr;
    }

    function setLocalOpenWorkContract(address _addr) external onlyMainDAO {
        localOpenWorkContract = _addr;
    }

    function setRewardsTracking(address _addr) external onlyMainDAO {
        rewardsTracking = _addr;
    }

    function setPayoutContracts(address _addr) external onlyMainDAO {
        payoutContracts = _addr;
    }

    function setMainTokenContract(address _addr) external onlyMainDAO {
        mainTokenContract = _addr;
    }
}