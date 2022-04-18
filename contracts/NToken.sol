// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

// import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./interfaces/IVault.sol";
import "./interfaces/INToken.sol";
import "./libraries/Errors.sol";

contract NToken is ERC20, INToken {
    
    IVault internal vault;

    modifier onlyVault {
        require(msg.sender == address(vault), Errors.CT_CALLER_MUST_BE_VAULT);
        _;
    }

    constructor(
        IVault _vault,
        string memory _nTokenName,
        string memory _nTokenSymbol
    ) ERC20(_nTokenName, _nTokenSymbol) {
        vault = _vault;
    }

    function mint(
        address user,
        uint256 amount
    ) external override onlyVault {
        require(amount != 0, Errors.VL_INVALID_AMOUNT);
        _mint(user, amount);
        emit Mint(user, amount);
    }

    function burn(
        address user,
        uint256 amount
    ) external override onlyVault {
        require(amount != 0, Errors.VL_INVALID_AMOUNT);
        _burn(user, amount);
        emit Burn(user, amount);
    }

    function scaledTotalSupply() external view override returns (uint256) {
        return super.totalSupply();
    }

    function getUserBalance(address user) external view override returns (uint256) {
        return super.balanceOf(user);
    }
}