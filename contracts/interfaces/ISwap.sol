// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

interface ISwap {
    function wBNB() external pure returns(address);

    function swapBNBForTokens(
        address _tokenOut,
        uint256 _amountOutMin,
        address _to
    ) external payable;

    function swapTokensForBNB(
        address _tokenIn,
        uint256 _amountIn,
        uint256 _amountOutMin,
        address _to
    ) external;

    function getAmountOutMin(
        address _tokenIn,
        address _tokenOut,
        uint256 _amountIn
    )  external view returns (uint);

    function swapTokensForTokens(
        address _tokenIn,
        address _tokenOut,
        uint256 _amountIn,
        uint256 _amountOutMin,
        address _to
    ) external;
}