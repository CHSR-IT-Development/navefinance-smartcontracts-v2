// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "./ISwap.sol";
import "../libraries/DataTypes.sol";

interface IRegistry {
    function registerVault(
        DataTypes.VaultData calldata _vaultData,
        uint256 _entryFeeRate,
        uint256 _maintenanceFeeRate,
        uint256 _performanceFeeRate,
        ISwap _swap
    ) external;

    function isRegistered(
        string memory _vaultName
    ) external view returns(bool);

    function vaultAddress(
        string memory _vaultName
    ) external view returns(address);

    function vaultCreator(
        address _vault
    ) external view returns(address);

    function platformFeeRate() external view returns(uint256);

    function maxNumTokens() external view returns(uint256);
}