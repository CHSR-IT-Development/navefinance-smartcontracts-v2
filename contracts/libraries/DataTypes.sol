// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

library DataTypes {
    struct VaultData {
        string vaultName;
        string nTokenName;
        string nTokenSymbol;
        address[] tokenAddresses;
        uint256[] percents;
    }
    
    struct TokenOut {
        address tokenAddress;
        uint256 percent;
    }
}