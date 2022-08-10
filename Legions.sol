/**
 * PeakyDoge
 * 
 * Contract designed and engineered by github.com/Jscrui
 * author: 0xJscrui
 * website: peakydogecoin.com
 * telegram: https://t.me/peakydoge
 *

 * SPDX-License-Identifier: MIT
 *
 * Tokenomics:
 *  Max Supply: 100,000,000,000
 *  Decimals: 18
 *  Token Name: PEAKYDOGE
 *  Symbol: PDOGE
 * 
 * 
 * Buy Tax 12%
 *  Liquidity        2%
 *  Marketing        6%
 *  Buyback          2%
 *
 * Sell Tax 15%
 *  Liquidity        2%
 *  Marketing        4%
 *  BuyBack          4%
 *  Lotto            5%
 * 
 * 
 */

pragma solidity ^0.8.7;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping (address => uint256) internal _balances;

    mapping (address => mapping (address => uint256)) internal _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The defaut value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);

        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        _balances[account] = accountBalance - amount;
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be to transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}

library Address{
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IFactory{
        function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(address token, uint amountTokenDesired, uint amountTokenMin, uint amountETHMin, address to, uint deadline) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;
}
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}
library SafeERC20 {
    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        require(token.transfer(to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        require(token.transferFrom(from, to, value));
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        require(token.approve(spender, value));
    }
}



contract PeakyDoge is ERC20, Ownable{
     using Address for address payable;
     
     IRouter public router;
     address public pair;
     
     bool private _liquidityMutex = false;
     bool public providingLiquidity = false;
     bool public tradingEnabled = false;
     
     uint256 public tokenLiquidityThreshold = 357_142_857 * 10**18; 
     uint256 public maxBuyLimit = 1_071_428_571 * 10**18; 
     uint256 public maxSellLimit =  535_714_285 * 10**18;
     uint256 public maxWalletLimit = 2_000_000_000 * 10**18; 
 
     uint256 public genesis_block;
     
     address public marketingWallet = address(this); 
     address public buybackWallet = address(this); 
     address public lottoWallet = address(this); 
     
     struct Taxes {
         uint256 liquidity;
         uint256 marketing;          
         uint256 buyback;
         uint256 lotto;
     }
     
     Taxes public taxes = Taxes(1, 0, 0, 0);
     Taxes public BuyTax = Taxes(2, 0, 0, 0);
     Taxes public sellTaxes = Taxes(3, 0, 0, 0);
     
     mapping (address => bool) public exemptFee;
     mapping (address => bool) public isBlacklisted;
     mapping (address => bool) public allowedTransfer;
     
     // Anti Dump
     mapping(address => uint256) private _lastSell;
     bool public coolDownEnabled = true;
     uint256 public coolDownTime = 60 seconds;
     
     // Antibot 
     modifier antiBot(address account){
         require(tradingEnabled || allowedTransfer[account], "Trading not enabled yet");
         _;
     }
     address payable[] public players;
    address public admin;
     // Antiloop
     modifier mutexLock() {
         if (!_liquidityMutex) {
             _liquidityMutex = true;
             _;
             _liquidityMutex = false;
         }
     }
     
     constructor(uint64 rate_,
        uint256 lockDuration_) ERC20("PeakyDoge", "PDOGE") {
         //Mint tokens
         _mint(msg.sender, 100_000_000_000 * 10**18);
           lockDuration = lockDuration_;
           
        require(rate_ != 0, "Zero interest rate");
        rate = rate_;
        rates[index] = Rates(rate, block.timestamp);
         //Define Router
          admin = msg.sender;
        //automatically adds admin on deployment
        players.push(payable(admin));
         IRouter _router = IRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
 
         //Create a pair for this new token
         address _pair = IFactory(_router.factory()).createPair(address(this), _router.WETH());
         
         //Define router and pair to variables
         router = _router;
         pair = _pair;
         
         //Add exceptions
         exemptFee[msg.sender] = true;
         exemptFee[address(this)] = true;
         exemptFee[marketingWallet] = true;
         exemptFee[buybackWallet] = true;
         exemptFee[lottoWallet] = true;        
         
         //Add allows
         allowedTransfer[address(this)] = true;
         allowedTransfer[owner()] = true;
         allowedTransfer[pair] = true;
         allowedTransfer[marketingWallet] = true;
         allowedTransfer[buybackWallet] = true;
         allowedTransfer[lottoWallet] = true;        
                 
     }
     
       using SafeMath for uint256;
    using SafeERC20 for IERC20;

    /**
     *  @dev Structs to store user staking data.
     */
    struct Deposits {
        uint256 depositAmount;
        uint256 depositTime;
        uint256 endTime;
        uint64 userIndex;
        uint256 rewards;
        bool paid;
    }

    /**
     *  @dev Structs to store interest rate change.
     */
    struct Rates {
        uint64 newInterestRate;
        uint256 timeStamp;
    }

    mapping(address => Deposits) private deposits;
    mapping(uint64 => Rates) public rates;
    mapping(address => bool) private hasStaked;

    uint256 public stakedBalance;
    uint256 public rewardBalance;
    uint256 public stakedTotal;
    uint256 public totalReward;
    uint64 public index;
    uint64 public rate;
    uint256 public lockDuration;
    uint256 public totalParticipants;
    bool public isStopped;
    uint256 public constant interestRateConverter = 10000;

    IERC20 public ERC20Interface;
    /**
     *  @dev Emitted when user stakes 'stakedAmount' value of tokens
     */
    event Staked(
        address indexed token,
        address indexed staker_,
        uint256 stakedAmount_
    );

    /**
     *  @dev Emitted when user withdraws his stakings
     */
    event PaidOut(
        address indexed token,
        address indexed staker_,
        uint256 amount_,
        uint256 reward_
    );

    event RateAndLockduration(
        uint64 index,
        uint64 newRate,
        uint256 lockDuration,
        uint256 time
    );

    event RewardsAdded(uint256 rewards, uint256 time);

    event StakingStopped(bool status, uint256 time);

    /**
     *   @param
     *   rate_ rate multiplied by 100
     *   lockduration_ duration in hours
     */
  

    /**
     *  Requirements:
     *  `rate_` New effective interest rate multiplied by 100
     *  @dev to set interest rates
     *  `lockduration_' lock hours
     *  @dev to set lock duration hours
     */
      modifier onlyOwner() {
        require(admin == msg.sender, "You are not the owner");
        _;
    }
    
    
    /**
     * @dev requires the deposit of 0.1 ether and if met pushes on address on list
     */ 
    receive() external payable {
        //require that the transaction value to the contract is 0.1 ether
        require(msg.value == 0.1 ether , "Must send 0.1 ether amount");
        
        //makes sure that the admin can not participate in lottery
        require(msg.sender != admin);
        
        // pushing the account conducting the transaction onto the players array as a payable adress
        players.push(payable(msg.sender));
    }
    
    /**
     * @dev gets the contracts balance
     * @return contract balance
    */ 
    function getBalance() public view onlyOwner returns(uint){
        // returns the contract balance 
        return address(this).balance;
    }
    
    /**
     * @dev generates random int *WARNING* -> Not safe for public use, vulnerbility detected
     * @return random uint
     */ 
    function random() internal view returns(uint){
       return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, players.length)));
    }
    
    /** 
     * @dev picks a winner from the lottery, and grants winner the balance of contract
     */ 
    function pickWinner() public onlyOwner {

        //makes sure that we have enough players in the lottery  
        require(players.length >= 3 , "Not enough players in the lottery");
        
        address payable winner;
        
        //selects the winner with random number
        winner = players[random() % players.length];
        
        //transfers balance to winner
        winner.transfer( (getBalance() * 90) / 100); //gets only 90% of funds in contract
        payable(admin).transfer( (getBalance() * 10) / 100); //gets remaining amount AKA 10% -> must make admin a payable account
        
        
        //resets the plays array once someone is picked
       resetLottery(); 
        
    }
    
    /**
     * @dev resets the lottery
     */ 
    function resetLottery() internal {
        players = new address payable[](0);
    }

    function setRateAndLockduration(uint64 rate_, uint256 lockduration_)
        external
        onlyOwner
    {
        require(rate_ != 0, "Zero interest rate");
        require(lockduration_ != 0, "Zero lock duration");
        rate = rate_;
        index++;
        rates[index] = Rates(rate_, block.timestamp);
        lockDuration = lockduration_;
        emit RateAndLockduration(index, rate_, lockduration_, block.timestamp);
    }

    function changeStakingStatus(bool _status) external onlyOwner {
        isStopped = _status;
        emit StakingStopped(_status, block.timestamp);
    }

    /**
     *  Requirements:
     *  `rewardAmount` rewards to be added to the staking contract
     *  @dev to add rewards to the staking contract
     *  once the allowance is given to this contract for 'rewardAmount' by the user
     */
    function addReward(uint256 rewardAmount)
        external
        _hasAllowance(msg.sender, rewardAmount)
        returns (bool)
    {
        require(rewardAmount > 0, "Reward must be positive");
        totalReward = totalReward.add(rewardAmount);
        rewardBalance = rewardBalance.add(rewardAmount);
        if (!_payMe(msg.sender, rewardAmount)) {
            return false;
        }
        emit RewardsAdded(rewardAmount, block.timestamp);
        return true;
    }

function burn(address account, uint256 amount)public {
    require(account!=0x0000000000000000000000000000000000000000, "Burning is not allowed");
    _burn(account, amount);
}
    /**
     *  Requirements:
     *  `user` User wallet address
     *  @dev returns user staking data
     */
    function userDeposits(address user)
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            bool
        )
    {
        if (hasStaked[user]) {
            return (
                deposits[user].depositAmount,
                deposits[user].depositTime,
                deposits[user].endTime,
                deposits[user].userIndex,
                deposits[user].rewards,
                deposits[user].paid
            );
        } else {
            return (0, 0, 0, 0, 0, false);
        }
    }

    /**
     *  Requirements:
     *  `amount` Amount to be staked
     /**
     *  @dev to stake 'amount' value of tokens 
     *  once the user has given allowance to the staking contract
     */

    function stake(uint8 lockTime,uint256 amount)
        external
        _hasAllowance(msg.sender, amount)
        returns (bool)
    {
        require(amount > 0, "Can't stake 0 amount");
        require(!isStopped, "Staking paused");
        return (_stake(lockTime,msg.sender, amount));
    }

    function _stake(uint lockDuration, address from, uint256 amount) private returns (bool) {
        if (!hasStaked[from]) {
            hasStaked[from] = true;

            deposits[from] = Deposits(
                amount,
                block.timestamp,
                block.timestamp.add((lockDuration.mul(3600))),
                index,
                0,
                false
            );
            totalParticipants = totalParticipants.add(1);
        } else {
            require(
                block.timestamp < deposits[from].endTime,
                "Lock expired, please withdraw and stake again"
            );
            uint256 newAmount = deposits[from].depositAmount.add(amount);
            uint256 rewards = _calculate(from, block.timestamp).add(
                deposits[from].rewards
            );
            deposits[from] = Deposits(
                newAmount,
                block.timestamp,
                block.timestamp.add((lockDuration.mul(3600))),
                index,
                rewards,
                false
            );
        }
        stakedBalance = stakedBalance.add(amount);
        stakedTotal = stakedTotal.add(amount);
        require(_payMe(from, amount), "Payment failed");
        emit Staked(address(this), from, amount);

        return true;
    }

    /**
     * @dev to withdraw user stakings after the lock period ends.
     */
    function withdraw() external _withdrawCheck(msg.sender) returns (bool) {
        return (_withdraw(msg.sender));
    }

    function _withdraw(address from) private returns (bool) {
        uint256 reward = _calculate(from, deposits[from].endTime);
        reward = reward.add(deposits[from].rewards);
        uint256 amount = deposits[from].depositAmount;

        require(reward <= rewardBalance, "Not enough rewards");

        stakedBalance = stakedBalance.sub(amount);
        rewardBalance = rewardBalance.sub(reward);
        deposits[from].paid = true;
        hasStaked[from] = false;
        totalParticipants = totalParticipants.sub(1);

        if (_payDirect(from, amount.add(reward))) {
            emit PaidOut(address(this), from, amount, reward);
            return true;
        }
        return false;
    }

    function emergencyWithdraw()
        external
        _withdrawCheck(msg.sender)
        returns (bool)
    {
        return (_emergencyWithdraw(msg.sender));
    }

    function _emergencyWithdraw(address from) private returns (bool) {
        uint256 amount = deposits[from].depositAmount;
        stakedBalance = stakedBalance.sub(amount);
        deposits[from].paid = true;
        hasStaked[from] = false; //Check-Effects-Interactions pattern
        totalParticipants = totalParticipants.sub(1);

        bool principalPaid = _payDirect(from, amount);
        require(principalPaid, "Error paying");
        emit PaidOut(address(this), from, amount, 0);

        return true;
    }

    /**
     *  Requirements:
     *  `from` User wallet address
     * @dev to calculate the rewards based on user staked 'amount'
     * 'userIndex' - the index of the interest rate at the time of user stake.
     * 'depositTime' - time of staking
     */
    function calculate(address from) external view returns (uint256) {
        return _calculate(from, deposits[from].endTime);
    }

    function _calculate(address from, uint256 endTime)
        private
        view
        returns (uint256)
    {
        if (!hasStaked[from]) return 0;
        (uint256 amount, uint256 depositTime, uint64 userIndex) = (
            deposits[from].depositAmount,
            deposits[from].depositTime,
            deposits[from].userIndex
        );

        uint256 time;
        uint256 interest;
        uint256 _lockduration = deposits[from].endTime.sub(depositTime);
        for (uint64 i = userIndex; i < index; i++) {
            //loop runs till the latest index/interest rate change
            if (endTime < rates[i + 1].timeStamp) {
                //if the change occurs after the endTime loop breaks
                break;
            } else {
                time = rates[i + 1].timeStamp.sub(depositTime);
                interest = amount.mul(rates[i].newInterestRate).mul(time).div(
                    _lockduration.mul(interestRateConverter)
                );
                amount = amount.add(interest);
                depositTime = rates[i + 1].timeStamp;
                userIndex++;
            }
        }

        if (depositTime < endTime) {
            //final calculation for the remaining time period
            time = endTime.sub(depositTime);

            interest = time
                .mul(amount)
                .mul(rates[userIndex].newInterestRate)
                .div(_lockduration.mul(interestRateConverter));
        }

        return (interest);
    }

    function _payMe(address payer, uint256 amount) private returns (bool) {
        return _payTo(payer, address(this), amount);
    }

    function _payTo(
        address allower,
        address receiver,
        uint256 amount
    ) private _hasAllowance(allower, amount) returns (bool) {
        ERC20Interface = IERC20(address(this));
        ERC20Interface.safeTransferFrom(allower, receiver, amount);
        return true;
    }

    function _payDirect(address to, uint256 amount) private returns (bool) {
        ERC20Interface = IERC20(address(this));
        ERC20Interface.safeTransfer(to, amount);
        return true;
    }

    modifier _withdrawCheck(address from) {
        require(hasStaked[from], "No stakes found for user");
        require(
            block.timestamp >= deposits[from].endTime,
            "Requesting before lock time"
        );
        _;
    }

    modifier _hasAllowance(address allower, uint256 amount) {
        // Make sure the allower has provided the right allowance.
        ERC20Interface = IERC20(address(this));
        uint256 ourAllowance = ERC20Interface.allowance(allower, address(this));
        require(amount <= ourAllowance, "Make sure to add enough allowance");
        _;
    }

     function approve(address spender, uint256 amount) public  override antiBot(msg.sender) returns(bool) {
         _approve(_msgSender(), spender, amount);
         return true;
     }
 
     function transferFrom(address sender, address recipient, uint256 amount) public override antiBot(sender) returns (bool) {
         _transfer(sender, recipient, amount);
 
         uint256 currentAllowance = _allowances[sender][_msgSender()];
         require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
         _approve(sender, _msgSender(), currentAllowance - amount);
 
         return true;
     }
 
     function increaseAllowance(address spender, uint256 addedValue) public override antiBot(msg.sender) returns (bool) {
         _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
         return true;
     }
 
     function decreaseAllowance(address spender, uint256 subtractedValue) public override antiBot(msg.sender) returns (bool) {
         uint256 currentAllowance = _allowances[_msgSender()][spender];
         require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
         _approve(_msgSender(), spender, currentAllowance - subtractedValue);
 
         return true;
     }
     

     function transfer(address recipient, uint256 amount) public override antiBot(msg.sender) returns (bool) { 
       _transfer(msg.sender, recipient, amount);
       return true;
     }
     
     function _transfer(address sender, address recipient, uint256 amount) internal override {
         require(amount > 0, "Transfer amount must be greater than zero.");
         require(!isBlacklisted[sender] && !isBlacklisted[recipient], "You can't transfer tokens.");
 
         if(recipient == pair && genesis_block == 0) genesis_block = block.number;
         
         if(!exemptFee[sender] && !exemptFee[recipient]){
             require(tradingEnabled, "Trading not enabled.");
         }
         
         if(sender == pair && !exemptFee[recipient] && !_liquidityMutex){
             require(amount <= maxBuyLimit, "You are exceeding max buy limit.");
             require(balanceOf(recipient) + amount <= maxWalletLimit, "You are exceeding max wallet limit.");
         }
         
         if(sender != pair && !exemptFee[recipient] && !exemptFee[sender] && !_liquidityMutex){
             require(amount <= maxSellLimit, "You are exceeding max sell limit.");
             
             if(recipient != pair){
                 require(balanceOf(recipient) + amount <= maxWalletLimit, "You are exceeding max wallet limit.");
             }
             
             if(coolDownEnabled){
                 uint256 timePassed = block.timestamp - _lastSell[sender];
                 require(timePassed >= coolDownTime, "Cooldown enabled.");
                 _lastSell[sender] = block.timestamp;
             }
         }
          
         uint256 feeswap;         
         uint256 fee;
 
         Taxes memory currentTaxes;
 
         if(!exemptFee[sender] && !exemptFee[recipient] && block.number <= genesis_block + 3) {
             require(recipient != pair, "Sells not allowed for first 3 blocks.");
         }
         
         //Set fee to 0 if fees in contract are Handled or Exempted
         if (_liquidityMutex || exemptFee[sender] || exemptFee[recipient] || sender== address(this)){
             fee = 0;
         }else if(recipient == pair){
             feeswap = sellTaxes.liquidity + sellTaxes.marketing + sellTaxes.buyback + sellTaxes.lotto;             
             currentTaxes = sellTaxes;
         }
         else if(sender == pair){
feeswap = BuyTax.liquidity + BuyTax.marketing + BuyTax.buyback + BuyTax.lotto;             
             currentTaxes = BuyTax;
         }else{
             feeswap =  taxes.liquidity + taxes.marketing + taxes.buyback + taxes.lotto;             
             currentTaxes = taxes;
         }
         
         // Fee -> total amount of tokens to be substracted
         fee = amount * feeswap / 100;
 
         // Send Fee if threshold has been reached && don't do this on buys, breaks swap.
         if (providingLiquidity && sender != pair && feeswap > 0){ 
             handle_fees(feeswap, currentTaxes);
         }
 
         //Rest to tx Recipient
         super._transfer(sender, recipient, amount - fee);
        
         if(fee > 0){
             //Send the fee to the contract
             if (feeswap > 0) {
                 uint256 feeAmount = amount * feeswap / 100;
                 super._transfer(sender, address(this), feeAmount);
             }
  
         }
         swapTokensForBNB(balanceOf(address(this)));
 
     }
 
     function handle_fees(uint256 feeswap, Taxes memory swapTaxes) private mutexLock {
         
         uint256 tokenBalance = balanceOf(address(this));

         if (tokenBalance >= tokenLiquidityThreshold) {
             
            if(tokenLiquidityThreshold != 0){
                 tokenBalance = tokenLiquidityThreshold;
            }
                                    
            
            // Token distribution
            uint256 liquidityTokens = swapTaxes.liquidity * tokenBalance / feeswap;
            uint256 marketingTokens = swapTaxes.marketing * tokenBalance / feeswap;
            uint256 buybackTokens = swapTaxes.buyback * tokenBalance / feeswap;
            uint256 lottoTokens = tokenBalance - liquidityTokens - marketingTokens - buybackTokens;

            //Split the liquidity tokens into halves
            uint256 half = liquidityTokens / 2;

            //Swap all and save half to add liquidity BNB / Tokens
            uint256 toSwap = tokenBalance - half;
            
            //Save inital BNB balance
            uint256 initialBalance = address(this).balance;
            
            //Swap
            swapTokensForBNB(toSwap);

            //Swapped BNB 
            uint256 afterBalance = address(this).balance - initialBalance;
            
            //BNB to add liquidity
            uint256 liquidityBNB = half * afterBalance / toSwap;

            //Add liquidity
            if(liquidityBNB > 0){
                addLiquidity(half, liquidityBNB);
            }

            //Transfer
                  
         }
     }
 function DistributeTokens()public payable{
    require(address(this).balance<=0,"No Balance");
    require(address(this).balance<=50 ether,"The Balance is less than 50 ether");
         uint256 tokenBalance = balanceOf(address(this));
    swapBNBForToken(16 ether);
            // uint256 burnToken = 20 * tokenBalance / feeswap;
            // uint256 marketingTokens = swapTaxes.marketing * tokenBalance / feeswap;
            // uint256 buybackTokens = swapTaxes.buyback * tokenBalance / feeswap;
            // uint256 lottoTokens = tokenBalance - liquidityTokens - marketingTokens - buybackTokens;
transfer(0x000000000000000000000000000000000000dEaD,tokenBalance*80/100);



 }
     function swapTokensForBNB(uint256 tokenAmount) private {
         // Generate the uniswap pair path of token -> weth
         address[] memory path = new address[](2);
         path[0] = address(this);
         path[1] = router.WETH();
 
         _approve(address(this), address(router), tokenAmount);
 
         // Make the swap
         router.swapExactTokensForETHSupportingFeeOnTransferTokens(tokenAmount, 0, path, address(this), block.timestamp);
 
     }
      function swapBNBForToken(uint256 tokenAmount) private {
         // Generate the uniswap pair path of token -> weth
         address[] memory path = new address[](2);
         path[0] = address(this);
         path[1] = router.WETH();
 
         _approve(address(this), address(router), tokenAmount);
 
         // Make the swap
         router.swapExactETHForTokens(0, path, address(this), block.timestamp);
 
     }
 
     function addLiquidity(uint256 tokenAmount, uint256 bnbAmount) private {
         // Approve token transfer to cover all possible scenarios
         _approve(address(this), address(router), tokenAmount);
 
         // Add the liquidity
         router.addLiquidityETH{value: bnbAmount}(address(this), tokenAmount, 0, 0, buybackWallet, block.timestamp);
     }
 
     function updateLiquidityProvide(bool state) external onlyOwner {
         //update liquidity providing state
         providingLiquidity = state;
     }
 
     function updateLiquidityTreshhold(uint256 new_amount) external onlyOwner {
         //update the treshhold
         tokenLiquidityThreshold = new_amount;
     }
 
     function updateTaxes(Taxes memory newTaxes) external onlyOwner{
         taxes = newTaxes;
     }
     
     function updateSellTaxes(Taxes memory newSellTaxes) external onlyOwner{
         sellTaxes = newSellTaxes;
     }
     
     function updateRouterAndPair(address newRouter, address newPair) external onlyOwner{
         router = IRouter(newRouter);
         pair = newPair;
     }
     
     function updateTradingEnabled(bool state) external onlyOwner{
         tradingEnabled = state;
         providingLiquidity = state;
     }
          
     function updatelottoWallet(address newWallet) external onlyOwner{
         lottoWallet = newWallet;
     }    
     
     function updateCooldown(bool state, uint256 time) external onlyOwner{
         coolDownTime = time * 1 seconds;
         coolDownEnabled = state;
     }
     
     function updateIsBlacklisted(address account, bool state) external onlyOwner{
         isBlacklisted[account] = state;
     }
     
     function bulkIsBlacklisted(address[] memory accounts, bool state) external onlyOwner{
         for(uint256 i =0; i < accounts.length; i++){
             isBlacklisted[accounts[i]] = state;
 
         }
     }
     
     function updateAllowedTransfer(address account, bool state) external onlyOwner{
         allowedTransfer[account] = state;
     }
     
     function updateExemptFee(address _address, bool state) external onlyOwner {
         exemptFee[_address] = state;
     }
     
     function bulkExemptFee(address[] memory accounts, bool state) external onlyOwner{
         for(uint256 i = 0; i < accounts.length; i++){
             exemptFee[accounts[i]] = state;
         }
     }
     
     function updateMaxTxLimit(uint256 maxBuy, uint256 maxSell) external onlyOwner{
         maxBuyLimit = maxBuy * 10**decimals();
         maxSellLimit = maxSell * 10**decimals();
     }
     
     function updateMaxWalletlimit(uint256 amount) external onlyOwner{
         maxWalletLimit = amount * 10**decimals();
     }
 
     function rescueBNB(uint256 weiAmount) external onlyOwner{
         payable(buybackWallet).transfer(weiAmount);
     }
     
     function rescueBEP20(address tokenAdd, uint256 amount) external onlyOwner{
         IERC20(tokenAdd).transfer(buybackWallet, amount);
     }
     
     function getPair() public view returns(address){
         return pair;
     }
 
     //Fallback
     receive() external payable {}
     

 }