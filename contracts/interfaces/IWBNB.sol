// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

interface IWBNB {
    function deposit() external payable;

    function withdraw(uint wad) external;

    function totalSupply() external view returns(uint);
    
    function approve(address guy, uint wad) external returns(bool);

    function transfer(address dst, uint wad) external returns(bool);

    function balanceOf(address account) external view returns (uint256);
}