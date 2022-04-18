// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

interface IVault {
    event Initialized(
        address indexed vaultAddress,
        address indexed creator, 
        string vaultName, 
        string nTokenName, 
        string nTokenSymbol,
        address[] tokenAddresses,
        uint256[] percents,
        uint256 entryFeeRate,
        uint256 maintenanceFeeRate,
        uint256 performanceFeeRate
    );
    
    event EditTokens(
        address indexed vaultAddress,
        address indexed creator,
        address[] newTokenAddresses,
        uint256[] newPercents
    );

    event TakeFee(
        address indexed treasury,
        address indexed vaultAddress,
        address indexed creator,
        uint256 creatorFee,
        uint256 platformFee
    );

    event Deposit(
        address indexed vaultAddress,
        address indexed creator,
        address indexed investor, 
        uint256 amountInBNB, 
        uint256 amountInBUSD,
        uint256 entryFee
    );

    event Withdraw(address indexed to, uint256 amount);
    
    function deposit() external payable;
    function withdraw(uint256 _amount) external;
}