// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

library Errors {
    string public constant VL_INVALID_AMOUNT = "1"; // Amount must be greater than 0
    string public constant VL_INVALID_TOKENOUTS = "2"; // Token to be distributed does not exist
    string public constant CT_CALLER_MUST_BE_VAULT = "3"; // The caller of this function must be a lending pool
    string public constant VL_NOT_CREATOR = "4"; // Not vault creator
    string public constant VL_NOT_INVESTOR = "5"; // Not vault investor
    string public constant VL_WITHDRAW_FAILED = "6"; // Failed to withdraw
    string public constant VL_NOT_ENOUGH_AMOUNT = "7"; // Not enough amount
    string public constant EXCEED_MAX_NUMBER = "8"; // Exceed max number of tokens
    string public constant VAULT_NAME_DUP = "9"; // Duplicated vault name
    string public constant NOT_ADMIN = "10"; // Not admin
    string public constant ZERO_PLATFORM_FEE = "11"; // No investors, no platform fee
    string public constant NOT_ZERO_ADDRESS = "12"; // No zero address
}