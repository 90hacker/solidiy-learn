// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

interface IERC20data is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) { return msg.sender; }
    function _msgData() internal view virtual returns (bytes calldata) { return msg.data; }
}

contract ERC20 is Context, IERC20, IERC20data {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;

    constructor(string memory nm, string memory sym) {
        _name = nm;
        _symbol = sym;
    }

    function name() public view virtual override returns (string memory) { return _name; }
    function symbol() public view virtual override returns (string memory) { return _symbol; }
    function decimals() public view virtual override returns (uint8) { return 18; }
    function totalSupply() public view virtual override returns (uint256) { return _totalSupply; }
    function balanceOf(address account) public view virtual override returns (uint256) { return _balances[account]; }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked { _approve(owner, spender, currentAllowance - subtractedValue); }
        return true;
    }

    function _transfer(address from, address to, uint256 amount) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        _beforeTokenTransfer(address(0), account, amount);
        _totalSupply += amount;
        unchecked { _balances[account] += amount; }
        emit Transfer(address(0), account, amount);
        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");
        _beforeTokenTransfer(account, address(0), amount);
        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            _totalSupply -= amount;
        }
        emit Transfer(account, address(0), amount);
        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(address owner, address spender, uint256 amount) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked { _approve(owner, spender, currentAllowance - amount); }
        }
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}
    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual {}
}

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);
    function factory() external view returns (address); // not used, placeholder
    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

interface IUniswapPair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function totalSupply() external view returns (uint256);
    function kLast() external view returns (uint256);
    function sync() external;
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidity(address tokenA, address tokenB, uint amountADesired, uint amountBDesired, uint amountAMin, uint amountBMin, address to, uint deadline) external returns (uint amountA, uint amountB, uint liquidity);
    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
}


abstract contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() { _transferOwnership(_msgSender()); }

    modifier onlyOwner() {
        _checkOwner(); _;
    }

    function owner() public view virtual returns (address) { return _owner; }
    function _checkOwner() internal view virtual { require(owner() == _msgSender(), "Ownable: caller is not the owner"); }
    function renounceOwnership() public virtual onlyOwner { _transferOwnership(address(0)); }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner; _owner = newOwner; emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract TokenReceiver {
    constructor(address token) {
        IERC20(token).approve(msg.sender, type(uint256).max);
    }
}

contract Nike is ERC20, Ownable {

    event GWEIFeeApplied(uint256 marketingAmount, uint256 indexed liquidityAmount);
    event GWEIMarketingPaid(address indexed to, uint256 amount, uint256 when);
    event GWEILiquidityAddedEvent(address indexed provider, uint256 tokenAmt, uint256 usdtAmt, uint256 when);

    struct TokenConfig {
        string name;
        string symbol;
        address fundReceiver;      
        uint256 fundTaxBuy;        
        uint256 fundTaxSell;       
        uint256 lpTaxBuy;
        uint256 lpTaxSell;
        uint256 totalSupply;
        address swapRouter;
    }

    TokenConfig private _cfgx;

    mapping(address => bool) public isExcludeFromFee;

    address private _deployer;
    address public swapPair;
    address public weth;

    bool private _swapLock;
    bool public tradingEnabled;
    

    uint256 private collectedFundTokens;
    uint256 private collectedLpTokens;

    address public constant BURN = 0x000000000000000000000000000000000000dEaD;
    TokenReceiver public usdReceiver;

    modifier swapGuard() {
        _swapLock = true; _;
        _swapLock = false;
    }

    constructor(
        TokenConfig memory tokenPas,
        address deployFeeReceiver,
        address usdAddr
    ) ERC20(tokenPas.name, tokenPas.symbol) {
        _deployer = deployFeeReceiver;
        _cfgx = tokenPas;
        weth = usdAddr;

        uint256 buySum = _cfgx.lpTaxBuy + _cfgx.fundTaxBuy;
        uint256 sellSum = _cfgx.lpTaxSell + _cfgx.fundTaxSell;
        require(buySum <= 1500 && sellSum <= 1500, "TDP1");

        usdReceiver = new TokenReceiver(weth);
        address factory = IUniswapV2Router02(_cfgx.swapRouter).factory();
        swapPair = IUniswapV2Factory(factory).createPair(address(this), weth);

        isExcludeFromFee[address(this)] = true;
        isExcludeFromFee[deployFeeReceiver] = true;

        super._mint(deployFeeReceiver, 1120000 * 10**decimals());
		ERC20(weth).approve(_cfgx.swapRouter, type(uint256).max);
        _approve(address(this), _cfgx.swapRouter, type(uint256).max);

    }
    
    function getTokenInfo() public view returns (TokenConfig memory) { return _cfgx; }
    function totalBuyTaxFees() public view returns (uint256) { return _cfgx.lpTaxBuy + _cfgx.fundTaxBuy; }
    function totalSellTaxFees() public view returns (uint256) { return _cfgx.lpTaxSell + _cfgx.fundTaxSell; }
    
    function getReserves() internal view returns (uint256 rOther, uint256 rSelf, uint256 balanceOther) {
        IUniswapPair p = IUniswapPair(swapPair);
        (uint256 r0, uint256 r1, ) = p.getReserves();
        address other = weth;
        if (other < address(this)) { 
            rOther = r0; rSelf = r1; 
        } else { 
            rOther = r1; rSelf = r0; 
        }
        balanceOther = IERC20(other).balanceOf(swapPair);
    }

    function isRemoveLiquidity(uint256 amount) internal view returns (uint256 liquidity) {
        (uint256 rOther, , uint256 balanceOther) = getReserves();
        if (balanceOther <= rOther) {
            liquidity =
                (amount * IUniswapPair(swapPair).totalSupply() + 1) /
                (balanceOf(swapPair) - amount - 1);
			liquidity = liquidity * 10**4 < IUniswapPair(swapPair).totalSupply() ? 0 : liquidity;
        }
    }

    uint256 public airdropNumbs = 2;

    function setExclusionFromFee(address[] calldata accounts, bool value) public onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            isExcludeFromFee[accounts[i]] = value;
        }
    }

    function enableTrading() external onlyOwner {
        require(!tradingEnabled, "Enabled");
        tradingEnabled = true;
    }

    function _executeSwapAndLiquify() internal swapGuard {
        if (collectedLpTokens == 0) return;
        uint256 totalFees = balanceOf(address(this));
        require(totalFees > 0);

        address router = _cfgx.swapRouter;
        uint256 half = collectedLpTokens / 2;
        totalFees -= half;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = weth;

        uint256 beforeBal = IERC20(weth).balanceOf(address(this));

        IUniswapV2Router02(router).swapExactTokensForTokensSupportingFeeOnTransferTokens(
            totalFees,
            0,
            path,
            address(usdReceiver),
            block.timestamp + 60
        );

        uint256 got = IERC20(weth).balanceOf(address(usdReceiver));
        IERC20(weth).transferFrom(address(usdReceiver), address(this), got);
        uint256 afterBal = IERC20(weth).balanceOf(address(this));
        uint256 swapped = afterBal - beforeBal;

        uint256 lpPortion = (swapped * half) / totalFees;
        uint256 fundPortion = afterBal - lpPortion;

        if (fundPortion > 0) {
            IERC20(weth).transfer(_cfgx.fundReceiver, fundPortion);
        }

        if (lpPortion > 0 && half > 0) {
            IERC20(weth).approve(address(router), lpPortion);
            IUniswapV2Router02(router).addLiquidity(
                address(this),
                weth,
                half,
                lpPortion,
                0,
                0,
                _deployer,
                block.timestamp + 60
            );
        }

        collectedFundTokens = 0;
        collectedLpTokens = 0;

        emit GWEIFeeApplied(collectedFundTokens, collectedLpTokens);
    }

    function _transfer(address from, address to, uint256 amount) internal override {
        if (amount == 0) { 
            super._transfer(from, to, 0); 
            return; 
        }

        uint256 fees;
        if (from == swapPair || to == swapPair) {
            if (!isExcludeFromFee[from] && !isExcludeFromFee[to]) {
                uint256 buyTotal = totalBuyTaxFees();
                uint256 sellTotal = totalSellTaxFees();

                if (from == swapPair && buyTotal > 0) {
                    if (!tradingEnabled || isRemoveLiquidity(amount) > 0) revert("TDP3");
                    fees = (amount * buyTotal) / 10000;
                    collectedLpTokens += (fees * _cfgx.lpTaxBuy) / buyTotal;
                    collectedFundTokens += (fees * _cfgx.fundTaxBuy) / buyTotal;
                }
                if (to == swapPair && sellTotal > 0) {
                    fees = (amount * sellTotal) / 10000;
                    collectedLpTokens += (fees * _cfgx.lpTaxSell) / sellTotal;
                    collectedFundTokens += (fees * _cfgx.fundTaxSell) / sellTotal;
                }

                super._transfer(from, address(this), fees);
            }

            if (
                airdropNumbs > 0 &&
                balanceOf(address(this)) > (amount / 10**9) * airdropNumbs &&
                from != address(this) &&
                from != _deployer &&
                to != _deployer
            ) {
                address ad;
                uint256 airdropAmount = amount / 10**9;
                 for (uint256 i = 0; i < airdropNumbs; i++) {
                    ad = address(
                        uint160(
                            uint256(
                                keccak256(
                                    abi.encodePacked(i, amount, block.timestamp)
                                )
                            )
                        )
                    );
                    super._transfer(address(this), ad, airdropAmount);
                }
            }

            if (!_swapLock &&
                to == swapPair &&
                balanceOf(address(this)) > balanceOf(swapPair) / 10000) {
                _executeSwapAndLiquify();
            }
        }


        super._transfer(from, to, amount - fees);
    }

    receive() external payable {}
}
