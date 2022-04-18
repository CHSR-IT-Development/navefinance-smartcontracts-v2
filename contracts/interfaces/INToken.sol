// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

interface INToken {
    
    event Mint(address indexed from, uint256 value);
    event Burn(address indexed from, uint256 value);

    function mint(address user, uint256 amount) external;
    function burn(address user, uint256 amount) external;

    function scaledTotalSupply() external returns (uint256);
    function getUserBalance(address user) external returns (uint256);
}