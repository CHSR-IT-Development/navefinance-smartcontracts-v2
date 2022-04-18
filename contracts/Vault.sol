// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

// import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./interfaces/ISwap.sol";
import "./interfaces/IVault.sol";
import "./interfaces/IRegistry.sol";
import "./interfaces/INToken.sol";
import "./interfaces/IWBNB.sol";
import "./libraries/Errors.sol";
import "./NToken.sol";
import "./libraries/DataTypes.sol";

contract Vault is IVault {

    using SafeMath for uint256;
    // BUSD contract address on the testnet
    // address public constant BUSD = 0x8301F2213c0eeD49a7E28Ae4c3e91722919B8B47;
    // BUSD contract address on the mainnet
    address public constant BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    uint256 public constant MAX_BPS  = 100000;

    // treasury account to save Platform Fee
    address private treasury;

    // vault's creator address
    address public creator;

    // vault name
    string public vaultName;
    uint256 public numInvestors;

    mapping(address => uint256) public balances;
    mapping(address => bool) public isInvestor;
    
    INToken internal nToken;
    ISwap internal navePortfolioSwap;
    IRegistry internal registry;

    DataTypes.TokenOut[] public tokenOuts;

    uint256 public entryFeeRate;
    uint256 public maintenanceFeeRate;
    uint256 public performanceFeeRate;

    modifier validAmount(uint256 amount) {
        require(amount != 0, Errors.VL_INVALID_AMOUNT);
        _;
    }

    modifier onlyTreasury {
        require(msg.sender == treasury, Errors.NOT_ADMIN);
        _;
    }

    modifier onlyCreator {
        require(msg.sender == creator, Errors.VL_NOT_CREATOR);
        _;
    }

    modifier onlyInvestor {
        require(
            isInvestor[msg.sender] || msg.sender == creator || msg.sender == treasury, 
            Errors.VL_NOT_INVESTOR
        );
        _;
    }

    constructor(
        address _creator,
        address _treasury,
        DataTypes.VaultData memory _vaultData,
        uint256 _entryFeeRate,
        uint256 _maintenanceFeeRate,
        uint256 _performanceFeeRate,
        ISwap _navePortfolioSwap
    ) {
        creator = _creator;
        treasury = _treasury;
        
        vaultName = _vaultData.vaultName;

        entryFeeRate = _entryFeeRate;
        maintenanceFeeRate = _maintenanceFeeRate;
        performanceFeeRate = _performanceFeeRate;

        navePortfolioSwap = _navePortfolioSwap;
        registry = IRegistry(msg.sender);

        // Create LP Token(NToken) contract
        nToken = new NToken(
            IVault(address(this)), 
            _vaultData.nTokenName, 
            _vaultData.nTokenSymbol
        );
        
        // Store vault token distribution
        for (uint256 i = 0; i < _vaultData.tokenAddresses.length; i++) {
            tokenOuts.push(
                DataTypes.TokenOut(_vaultData.tokenAddresses[i], _vaultData.percents[i])
            );
        }

        emit Initialized(
            address(this),
            msg.sender, 
            _vaultData.vaultName, 
            _vaultData.nTokenName, 
            _vaultData.nTokenSymbol,
            _vaultData.tokenAddresses,
            _vaultData.percents,
            _entryFeeRate,
            _maintenanceFeeRate,
            _performanceFeeRate
        );
    }

    function deposit() external override payable validAmount(msg.value) {
        uint256 entryFee = 0;
        // Check if this is the first deposit.
        if(balances[msg.sender] == 0) {
            addInvestor(msg.sender);
        }
        
        entryFee = takeEntryFee(msg.sender, msg.value);

        uint256 inputAmount = msg.value - entryFee;
        balances[msg.sender] += inputAmount;

        uint256 preTVLInBUSD = 0;
        for (uint256 i = 0; i < tokenOuts.length; i++) {
            // Calculate TVL(pre-money) before deposit.
            uint256 tokenAmount = 
                IERC20(tokenOuts[i].tokenAddress).balanceOf(address(this));
            if (tokenAmount != 0) {
                preTVLInBUSD += ISwap(navePortfolioSwap).getAmountOutMin(
                    tokenOuts[i].tokenAddress,
                    BUSD,
                    tokenAmount
                );
            }
            // Distribute deposit amount(xBNB) into respective tokens.
            swapBNBForTokens(
                tokenOuts[i].tokenAddress, 
                inputAmount * tokenOuts[i].percent / 100
            );
        }
        // calculate input amount in BUSD
        uint256 amountInBUSD = ISwap(navePortfolioSwap).getAmountOutMin(
            ISwap(navePortfolioSwap).wBNB(),
            BUSD,
            inputAmount
        );
        
        // Mint LP Tokens
        if (preTVLInBUSD == 0) {
            INToken(nToken).mint(msg.sender, amountInBUSD);
        } else {
            uint256 nTokenSupply = INToken(nToken).scaledTotalSupply();
            INToken(nToken).mint(
                msg.sender, 
                amountInBUSD.mul(nTokenSupply).div(preTVLInBUSD)
            );
        }
        
        emit Deposit(address(this), creator, msg.sender, msg.value, amountInBUSD, entryFee);
    }

    /**
   * @dev Withdraws BNB from the vault, burning the equivalent nTokens `amount` owned
   * @param _amount The underlying amount to be withdrawn
   *   - Send the value type(uint256).max in order to withdraw the whole nToken balance
   **/

    function withdraw(uint256 _amount) external override onlyInvestor {
        if (_amount == type(uint256).max) {
            removeInvestor(msg.sender);
        }
        uint256 nTokenBalance = INToken(nToken).getUserBalance(msg.sender);
        require(_amount <= nTokenBalance, Errors.VL_NOT_ENOUGH_AMOUNT);

        for (uint256 i = 0; i < tokenOuts.length; i++) {
            uint256 tokenAmountToSwap = IERC20(tokenOuts[i].tokenAddress).balanceOf(address(this))
                .mul(_amount)
                .div(INToken(nToken).scaledTotalSupply());

            swapTokensForBNB(tokenOuts[i].tokenAddress, tokenAmountToSwap);
        }

        (bool sent, ) = msg.sender.call{value: address(this).balance}("");
        require(sent, Errors.VL_WITHDRAW_FAILED);
        
        // burn LP Token
        INToken(nToken).burn(msg.sender, _amount);
        emit Withdraw(msg.sender, _amount);
    }

    function nTokenAddress() external view returns(address) {
        return address(nToken);
    }

    function setEntryFee(uint256 _newEntryFeeRate) public onlyTreasury {
        entryFeeRate = _newEntryFeeRate;
    }

    function setTreasury(address _newTreasury) public onlyTreasury {
        require(_newTreasury != address(0), Errors.NOT_ZERO_ADDRESS);
        treasury = _newTreasury;
    }

    function addInvestor(address _newInvestor) internal {
        numInvestors++;
        isInvestor[_newInvestor] = true;
    }

    function removeInvestor(address _investor) internal {
        numInvestors--;
        delete isInvestor[_investor];
        delete balances[_investor];
    }

    function takeFees(uint256 nTokenAmount) 
        external 
        validAmount(nTokenAmount) 
        onlyTreasury 
    {
        // mint the given number of LP Tokens to the vault creator
        INToken(nToken).mint(creator, nTokenAmount);

        // calculate nToken amount for platform fee
        uint256 nTokenSupply = INToken(nToken).scaledTotalSupply();
        uint256 creatorAmount = INToken(nToken).getUserBalance(creator);

        uint256 platformFee = (IRegistry(registry).platformFeeRate())
            .mul(nTokenSupply.sub(creatorAmount))
            .div(MAX_BPS);

        require(platformFee > 0, Errors.ZERO_PLATFORM_FEE);
        INToken(nToken).mint(treasury, platformFee);

        // withdraw nToken amount into treasury wallet as BNB
        for (uint256 i = 0; i < tokenOuts.length; i++) {
            uint256 tokenAmountToSwap = IERC20(tokenOuts[i].tokenAddress).balanceOf(address(this))
                .mul(platformFee)
                .div(nTokenSupply);

            swapTokensForBNB(tokenOuts[i].tokenAddress, tokenAmountToSwap);
        }

        (bool sent, ) = treasury.call{value: address(this).balance}("");
        require(sent, Errors.VL_WITHDRAW_FAILED);
        
        // burn LP Token
        INToken(nToken).burn(treasury, platformFee);

        emit TakeFee(treasury, address(this), creator, nTokenAmount, platformFee);
    }

    function editTokens(
        address[] calldata _tokenAddresses,
        uint256[] calldata _percents
    ) external onlyCreator {
        require(_tokenAddresses.length > 0, Errors.VL_INVALID_TOKENOUTS);
        require(_tokenAddresses.length < IRegistry(registry).maxNumTokens(), Errors.EXCEED_MAX_NUMBER);
        
        for (uint256 i = 0; i < tokenOuts.length; i++) {
            uint256 tokenAmountToSwap = IERC20(tokenOuts[i].tokenAddress).balanceOf(address(this));
            
            swapTokensForBNB(tokenOuts[i].tokenAddress, tokenAmountToSwap);
        }
        // initialize tokenOuts array
        delete tokenOuts;

        // set new token distribution
        for (uint256 i = 0; i < _tokenAddresses.length; i++) {
            tokenOuts.push(
                DataTypes.TokenOut(_tokenAddresses[i], _percents[i])
            );
            swapBNBForTokens(
                tokenOuts[i].tokenAddress,
                address(this).balance * tokenOuts[i].percent / 100
            );
        }

        emit EditTokens(address(this), creator, _tokenAddresses, _percents);
    }

    function swapBNBForTokens(
        address tokenOut,
        uint256 bnbAmountToSwap
    ) internal {
        if (tokenOut == ISwap(navePortfolioSwap).wBNB()) {
            IWBNB(ISwap(navePortfolioSwap).wBNB()).deposit{
                value: bnbAmountToSwap
            }();
        } else {
            ISwap(navePortfolioSwap).swapBNBForTokens{
                value: bnbAmountToSwap
            }(
                tokenOut,
                0, 
                address(this)
            );
        }
    }

    function swapTokensForBNB(
        address tokenIn,
        uint256 amountToSwap
    ) internal {
        if (tokenIn == ISwap(navePortfolioSwap).wBNB()) {
            IWBNB(ISwap(navePortfolioSwap).wBNB()).withdraw(amountToSwap);
        } else {
            IERC20(tokenIn).approve(address(navePortfolioSwap), amountToSwap);
            ISwap(navePortfolioSwap).swapTokensForBNB(
                tokenIn,
                amountToSwap,
                0, 
                address(this)
            );
        }
    }

    function takeEntryFee(
        address investor,
        uint256 depositAmount
    ) internal returns(uint256) {
        uint256 entryFee = 0;
        if (investor == creator) return 0;
        entryFee = depositAmount.mul(entryFeeRate).div(MAX_BPS);
        (bool sent, ) = creator.call{value: entryFee}("");
        require(sent, "Failed to send entry fee into the creator wallet");
        return entryFee;
    }

    receive() external payable {}
}
