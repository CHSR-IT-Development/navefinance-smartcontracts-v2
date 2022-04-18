// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "./interfaces/ISwap.sol";
import "./Vault.sol";
import "./libraries/DataTypes.sol";

contract Registry {

    // administrator of Registry contract
    address private admin;
    // total number of vaults
    uint256 public numVaults;

    uint256 public platformFeeRate = 15;
    uint256 public maxNumTokens = 10;

    mapping(bytes32 => address) private vaults;
    mapping(address => address) private vaultCreators;

    constructor() {
        admin = msg.sender;
    }

    function registerVault(
        DataTypes.VaultData calldata _vaultData,
        uint256 _entryFeeRate,
        uint256 _maintenanceFeeRate,
        uint256 _performanceFeeRate,
        ISwap _swap
    ) external {
        bytes32 identifier = keccak256(abi.encodePacked(_vaultData.vaultName));
        // Check vault name existence
        require(vaults[identifier] == address(0), Errors.VAULT_NAME_DUP);

        require(_vaultData.tokenAddresses.length > 0, Errors.VL_INVALID_TOKENOUTS);
        require(_vaultData.tokenAddresses.length <= maxNumTokens, Errors.EXCEED_MAX_NUMBER);

        Vault vault = new Vault(
            msg.sender,
            admin,
            _vaultData,
            _entryFeeRate,
            _maintenanceFeeRate,
            _performanceFeeRate,
            _swap
        );
        vaults[identifier] = address(vault);
        vaultCreators[address(vault)] = msg.sender;
        numVaults++;
    }

    function isRegistered(
        string memory _vaultName
    ) external view returns(bool) {
        bytes32 identifier = keccak256(
            abi.encodePacked(
                _vaultName
            )
        );

        if(vaults[identifier] == address(0)) return false;
        else return true;
    }

    function vaultAddress(
        string memory _vaultName
    ) external view returns(address) {
        bytes32 identifier = keccak256(
            abi.encodePacked(
                _vaultName
            )
        );
        return vaults[identifier];
    }

    function vaultCreator(
        address _vault
    ) external view returns(address) {
        return vaultCreators[_vault];
    }

    function setPlatformFeeRate(uint256 _newPlatformFeeRate) public {
        platformFeeRate = _newPlatformFeeRate;
    }

    function setMaxNumTokens(uint256 _newMaxNumTokens) public {
        maxNumTokens = _newMaxNumTokens;
    }
}
