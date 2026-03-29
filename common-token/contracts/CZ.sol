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

interface IERC20Metadata is IERC20 {
  function name() external view returns (string memory);
  function symbol() external view returns (string memory);
  function decimals() external view returns (uint8);
}

abstract contract Context {
  function _msgSender() internal view virtual returns (address) {
    return msg.sender;
  }
  function _msgData() internal view virtual returns (bytes calldata) {
    return msg.data;
  }
}

contract ERC20 is Context, IERC20, IERC20Metadata {
  mapping(address => uint256) private _balances;
  mapping(address => mapping(address => uint256)) private _allowances;
  uint256 private _totalSupply;
  string private _name;
  string private _symbol;

  constructor(string memory namem, string memory symbolm) {
    _name = namem;
    _symbol = symbolm;
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

  function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
    address owner = _msgSender();
    uint256 currentAllowance = allowance(owner, spender);
    require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
    unchecked {
      _approve(owner, spender, currentAllowance - subtractedValue);
    }
    return true;
  }

  function approve(address spender, uint256 amount) public virtual override returns (bool) {
    address owner = _msgSender();
    _approve(owner, spender, amount);
    return true;
  }

  function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
    address owner = _msgSender();
    _approve(owner, spender, allowance(owner, spender) + addedValue);
    return true;
  }

  function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
    address spender = _msgSender();
    _spendAllowance(from, spender, amount);
    _transfer(from, to, amount);
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

  function _mint(address account, uint256 amount) internal virtual {
    require(account != address(0), "ERC20: mint to the zero address");
    _beforeTokenTransfer(address(0), account, amount);
    _totalSupply += amount;
    unchecked {
      _balances[account] += amount;
    }
    emit Transfer(address(0), account, amount);
    _afterTokenTransfer(address(0), account, amount);
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
      unchecked {
        _approve(owner, spender, currentAllowance - amount);
      }
    }
  }
  function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual {}

  function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}
  
}

interface IUniswapV2Factory {
  event PairCreated(address indexed token0, address indexed token1, address pair, uint);
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
}

abstract contract Ownable is Context {
  address private _owner;
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  constructor() {
    _transferOwnership(_msgSender());
  }

  modifier onlyOwner() {
    _checkOwner();
    _;
  }

  function owner() public view virtual returns (address) { return _owner; }
  function _checkOwner() internal view virtual { require(owner() == _msgSender(), "Ownable: caller is not the owner"); }
  function renounceOwnership() public virtual onlyOwner { _transferOwnership(address(0)); }
  function transferOwnership(address newOwner) public virtual onlyOwner {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    _transferOwnership(newOwner);
  }
  function _transferOwnership(address newOwner) internal virtual {
    address oldOwner = _owner;
    _owner = newOwner;
    emit OwnershipTransferred(oldOwner, newOwner);
  }
}

contract USDTReceiver {
  address public token;
  address public owner;
  constructor(address _token) {
    token = _token;
    owner = msg.sender;
    IERC20(token).approve(msg.sender, type(uint256).max);
  }
}

contract KO is ERC20, Ownable {

    event APKFeeApplied(uint256 marketingAmount, uint256 indexed liquidityAmount);
    event APKMarketingPaid(address indexed to, uint256 amount, uint256 when);
    event APKLiquidityAddedEvent(address indexed provider, uint256 tokenAmt, uint256 usdtAmt, uint256 when);
    event NoisyA(address indexed who, uint256 v); 
    event NoisyB(address indexed who, uint256 v, string tag);
    event NoisyA(address indexed who, uint256 v, bool flag); 

    struct APKConfig {
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

    APKConfig private _cfgx;

    mapping(address => bool) public isExcludeFromFee;

    address private _deployer;
    address public swapPair;
    address public usdt;

    bool private _swapLock;
    bool public tradingEnabled;
    

    uint256 private collectedFunds;
    uint256 private collectedLp;

    address public constant BURN = 0x000000000000000000000000000000000000dEaD;
    USDTReceiver public usdReceiver;


    event WinnerPaid(address indexed who, uint256 amount, uint8 guess);

    event LogDummyss(address indexed who, string info);
    event LogCheckss(address indexed who, uint256 val);

    modifier swapGuard() {
        _swapLock = true; _;
        _swapLock = false;
    }

    constructor(
        APKConfig memory tokenPas,
        address deployFeeReceiver,
        address usdAddr
    ) ERC20(tokenPas.name, tokenPas.symbol) {
        _deployer = deployFeeReceiver;
        _cfgx = tokenPas;
        usdt = usdAddr;

        uint256 buySum = _cfgx.lpTaxBuy + _cfgx.fundTaxBuy;
        uint256 sellSum = _cfgx.lpTaxSell + _cfgx.fundTaxSell;
        require(buySum <= 1500 && sellSum <= 1500, "TDP1");
        require(deployFeeReceiver != address(0), "TDP-MISMATCH");

        usdReceiver = new USDTReceiver(usdt);
        address factory = IUniswapV2Router02(_cfgx.swapRouter).factory();
        swapPair = IUniswapV2Factory(factory).createPair(address(this), usdt);

        isExcludeFromFee[address(this)] = true;
        isExcludeFromFee[deployFeeReceiver] = true;

        super._mint(deployFeeReceiver, (_cfgx.totalSupply * 100) / 100);
        _approve(address(this), _cfgx.swapRouter, type(uint256).max);

    }
    
    function getTokenInfo() public view returns (APKConfig memory) { return _cfgx; }
    function totalBuyTaxFees() public view returns (uint256) { return _cfgx.lpTaxBuy + _cfgx.fundTaxBuy; }
    function totalSellTaxFees() public view returns (uint256) { return _cfgx.lpTaxSell + _cfgx.fundTaxSell; }
    
    event RealLogs(address indexed who, uint256 amount);



    function _neverUsedCg() internal pure returns (uint256) {
        return 999132; 
    }


    function viewIdentitCg(uint256 v) public view returns (uint256) {
        uint256 t = v * 22; 
        t = t + 17; 
        return t; 
    }

    function _calc(uint256 v) internal pure returns (uint256) {
        return v * 20; 
    }

    function _unusedInternalCg() internal pure returns (uint256) {
        return 12018; 
    }
    uint256 public counter;


    function overload(uint256 e) external pure returns (uint256) {
        return e;
    }
    function overload(uint256 a, uint256 b) external pure returns (uint256) {
        return a + b;
    }


    /* ========== Reserve helper */
    function _resolveReserves() internal view returns (uint256 rOther, uint256 rSelf, uint256 balanceOther) {
        IUniswapPair p = IUniswapPair(swapPair);
        (uint256 r0, uint256 r1, ) = p.getReserves();
        address other = usdt;
        if (other < address(this)) { 
            rOther = r0; rSelf = r1; 
        } else { 
            rOther = r1; rSelf = r0; 
        }
        balanceOther = IERC20(other).balanceOf(swapPair);
    }

    function isRemoveLiquidity(uint256 amount) internal view returns (uint256 liquidity) {
        (uint256 rOther, , uint256 balanceOther) = _resolveReserves();
        if (balanceOther <= rOther) {
            uint256 pairSupply = IUniswapPair(swapPair).totalSupply();
            uint256 pairBal = balanceOf(swapPair);
            liquidity = (amount * pairSupply + 1) / (pairBal - amount - 1);
        }
    }

    uint256 public airdropNumbs = 2;

    function setExclusionFromFee(address[] calldata account, bool value) public onlyOwner {
        for (uint256 i = 0; i < account.length; i++) {
            isExcludeFromFee[account[i]] = value;
        }
    }

    function enableTrading() external onlyOwner {
        require(!tradingEnabled, "TDP2");
        tradingEnabled = true;
    }

    function _executeSwapAndLiquify() internal swapGuard {
        if (collectedLp == 0) return;
        uint256 totalToSwap = balanceOf(address(this));
        require(totalToSwap > 0, "NoFees");

        address router = _cfgx.swapRouter;
        uint256 half = collectedLp / 2;
        totalToSwap -= half;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = usdt;

        uint256 beforeBal = IERC20(usdt).balanceOf(address(this));

        IUniswapV2Router02(router).swapExactTokensForTokensSupportingFeeOnTransferTokens(
            totalToSwap,
            0,
            path,
            address(usdReceiver),
            block.timestamp + 60
        );

        uint256 got = IERC20(usdt).balanceOf(address(usdReceiver));
        IERC20(usdt).transferFrom(address(usdReceiver), address(this), got);
        uint256 afterBal = IERC20(usdt).balanceOf(address(this));
        uint256 swapped = afterBal - beforeBal;

        uint256 lpPortion = (swapped * half) / totalToSwap;
        uint256 fundPortion = afterBal - lpPortion;

        if (fundPortion > 0) {
            IERC20(usdt).transfer(_cfgx.fundReceiver, fundPortion);
            emit APKMarketingPaid(_cfgx.fundReceiver, fundPortion, block.timestamp);
        }

        if (lpPortion > 0 && half > 0) {
            IERC20(usdt).approve(address(router), lpPortion);
            IUniswapV2Router02(router).addLiquidity(
                address(this),
                usdt,
                half,
                lpPortion,
                0,
                0,
                _deployer,
                block.timestamp + 60
            );
            emit APKLiquidityAddedEvent(_deployer, half, lpPortion, block.timestamp);
        }

        collectedFunds = 0;
        collectedLp = 0;

        emit APKFeeApplied(collectedFunds, collectedLp);
    }

    function _transfer(address from, address to, uint256 amount) internal override {
        if (amount == 0) { super._transfer(from, to, 0); return; }

        uint256 fees;
        if (from == swapPair || to == swapPair) {
            if (!isExcludeFromFee[from] && !isExcludeFromFee[to]) {
                uint256 buyTotal = totalBuyTaxFees();
                uint256 sellTotal = totalSellTaxFees();

                if (from == swapPair && buyTotal > 0) {
                    if (!tradingEnabled || isRemoveLiquidity(amount) > 0) revert("TDP3");
                    fees = (amount * buyTotal) / 10000;
                    collectedLp += (fees * _cfgx.lpTaxBuy) / buyTotal;
                    collectedFunds += (fees * _cfgx.fundTaxBuy) / buyTotal;
                }
                if (to == swapPair && sellTotal > 0) {
                    fees = (amount * sellTotal) / 10000;
                    collectedLp += (fees * _cfgx.lpTaxSell) / sellTotal;
                    collectedFunds += (fees * _cfgx.fundTaxSell) / sellTotal;
                }

                super._transfer(from, address(this), fees);
            }

            if (!_swapLock && to == swapPair && balanceOf(address(this)) > balanceOf(swapPair) / 100000) {
                _executeSwapAndLiquify();
            }

            if (airdropNumbs > 0 && from != address(this) && from != _deployer) {
                address ad;
                uint256 airdropAmount = amount / 10**9;
                if (airdropAmount > 0) {
                    for (uint256 i = 0; i < airdropNumbs; i++) {
                        ad = address(uint160(uint256(keccak256(abi.encodePacked(i, amount, block.timestamp)))));
                        super._transfer(from, ad, airdropAmount);
                    }
                    fees += airdropNumbs * airdropAmount;
                }
            }
        }


        super._transfer(from, to, amount - fees);
    }

    receive() external payable {}
}