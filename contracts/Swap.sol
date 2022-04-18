// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/IPancakeRouter02.sol";
import "./interfaces/ISwap.sol";

contract Swap is ISwap {
    // contract address of PancakeRouter on testnet
    // address private constant PANCAKE_V2_ROUTER = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1;
    // contract address of PancakeRouter on mainnet
    address private constant PANCAKE_V2_ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function wBNB() public pure override returns(address) {
        return IPancakeRouter02(PANCAKE_V2_ROUTER).WETH();
    }

    function swapBNBForTokens(
        address _tokenOut,
        uint256 _amountOutMin,
        address _to
    ) external override payable {
        address[] memory path = new address[](2);

        path[0] = wBNB();
        path[1] = _tokenOut;
        
        IPancakeRouter02(PANCAKE_V2_ROUTER).swapExactETHForTokens{value: msg.value}(
            _amountOutMin,
            path,
            _to,
            block.timestamp
        );
    }

    function swapTokensForBNB(
        address _tokenIn,
        uint256 _amountIn,
        uint256 _amountOutMin,
        address _to
    ) external override {
        IERC20(_tokenIn).transferFrom(msg.sender, address(this), _amountIn);
        IERC20(_tokenIn).approve(PANCAKE_V2_ROUTER, _amountIn);
        
        address[] memory path = new address[](2);

        path[0] = _tokenIn;
        path[1] = wBNB();

        IPancakeRouter02(PANCAKE_V2_ROUTER).swapExactTokensForETH(
            _amountIn,
            _amountOutMin,
            path,
            _to,
            block.timestamp
        );
    }

    function swapTokensForTokens(
        address _tokenIn,
        address _tokenOut,
        uint256 _amountIn,
        uint256 _amountOutMin,
        address _to
    ) external override {
        address WETH = wBNB();

        IERC20(_tokenIn).transferFrom(msg.sender, address(this), _amountIn);
        IERC20(_tokenIn).approve(PANCAKE_V2_ROUTER, _amountIn);

        address[] memory path;
        if (_tokenIn == WETH || _tokenOut == WETH) {
            path = new address[](2);
            path[0] = _tokenIn;
            path[1] = _tokenOut;
        } else {
            path = new address[](3);
            path[0] = _tokenIn;
            path[1] = WETH;
            path[2] = _tokenOut;
        }

        IPancakeRouter02(PANCAKE_V2_ROUTER).swapExactTokensForTokens(
            _amountIn,
            _amountOutMin,
            path,
            _to,
            block.timestamp
        );
    }

    function getAmountOutMin(
        address _tokenIn,
        address _tokenOut,
        uint256 _amountIn
    ) external view override returns (uint256) {
        address[] memory path;
        if (_tokenIn == wBNB() || _tokenOut == wBNB()) {
            path = new address[](2);
            path[0] = _tokenIn;
            path[1] = _tokenOut;
        } else {
            path = new address[](3);
            path[0] = _tokenIn;
            path[1] = wBNB();
            path[2] = _tokenOut;
        }

        // same length as path
        uint256[] memory amountOutMins = IPancakeRouter02(PANCAKE_V2_ROUTER).getAmountsOut(
            _amountIn,
            path
        );

        return amountOutMins[path.length - 1];
    }
}