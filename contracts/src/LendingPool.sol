// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./MockPriceOracle.sol";

error ZeroAddress();
error AmountZero();
error TransferFailed();
error InsufficientCollateral();
error InsufficientLiquidity();
error HealthFactorTooLow();
error HealthFactorOk();


contract LendingPool  is ReentrancyGuard{

    using SafeERC20 for IERC20;

    // **********State**********
    IERC20 public immutable collateralToken;
    IERC20 public immutable stableToken;
    uint256 public borrowRate = 5e16;
    mapping(address => uint256) public lastBorrowTimestamp;

    MockPriceOracle public immutable priceOracle;

    mapping(address => uint256) internal collateralBalance;
    mapping(address => uint256) internal debtBalance;

    uint256 public totalDeposits;
    uint256 public totalBorrows;

    uint256 public constant LIQUIDATION_THRESHOLD = 80; // %
    uint256 public constant LTV = 75; // %
    uint256 public constant PRECISION = 1e18;
    uint256 public constant LIQUIDATION_BONUS = 5;

    // *********Events*******

    event Deposited(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event Borrowed(address indexed user, uint256 amount);
    event Repaid(address indexed user, uint256 amount);
    event Liquidated(
        address indexed liquidator,
        address indexed user,
        uint256 debtRepaid,
        uint256 collateralSeized
    );

    // ********CONSTRUCTOR************
    constructor(address _collateralToken, address _stableToken, address _oracle) {
        if (_collateralToken == address(0) || _stableToken == address(0) || _oracle == address(0)) {
            revert ZeroAddress();
        }
        collateralToken = IERC20(_collateralToken);
        stableToken = IERC20(_stableToken);
        priceOracle = MockPriceOracle(_oracle);
    }

    function getUserCollateral(address user) external view returns (uint256) {
        return collateralBalance[user];
    }

    function getUserDebt(address user) external view returns (uint256) {
        return debtBalance[user];
    }

// ************ DEPOSIT FUNCTION ********
/*
    deposit()

    Allows user to supply collateral to protocol.

    Flow:
    1. Validate amount
    2. Transfer tokens securely
    3. Update user balance
    4. Update protocol liquidity
    5. Emit event

    ReentrancyGuard prevents recursive calls.
*/
function deposit(uint256 amount) external nonReentrant {
    if (amount == 0) revert AmountZero();

    collateralToken.safeTransferFrom(
        msg.sender,
        address(this),
        amount
    );

    //update internal accounting
    collateralBalance[msg.sender]+= amount;
    totalDeposits+= amount;

    emit  Deposited(msg.sender, amount);
}


/*
    withdraw()

    Allows user to withdraw previously deposited collateral.

    Security considerations:
    - Prevent withdrawing more than deposited.
    - Reentrancy protection applied.
    - Accounting updated before token transfer.
*/
function withdraw(uint256 amount) external nonReentrant {
    if (amount == 0) revert AmountZero();

    uint256 userBalance = collateralBalance[msg.sender];
    if (userBalance < amount) revert InsufficientCollateral();

    // EFFECTS FIRST
    collateralBalance[msg.sender] -= amount;
    totalDeposits -= amount;

    // CRITICAL SAFETY CHECK
    if (debtBalance[msg.sender] > 0) {
        if (getHealthFactor(msg.sender) < PRECISION) {
            revert HealthFactorTooLow();
        }
    }

    // INTERACTION
    collateralToken.safeTransfer(msg.sender, amount);

    emit Withdrawn(msg.sender, amount);
}

/*
    Calculates user health factor.

    Health factor indicates liquidation safety:
    > 1 → safe
    < 1 → liquidatable
*/
function getHealthFactor(address user)
    public
    view
    returns (uint256)
{
    uint256 collateral = collateralBalance[user];
    uint256 debt = debtBalance[user];

    if (debt == 0) return type(uint256).max;

    uint256 price = priceOracle.getPrice();

    uint256 collateralValue =
        (collateral * price) / PRECISION;

    uint256 adjustedCollateral =
        (collateralValue * LIQUIDATION_THRESHOLD) / 100;

    return (adjustedCollateral * PRECISION) / debt;
}


function borrow(uint256 amount)external nonReentrant {
    if (amount == 0) revert AmountZero();

    uint256 collateral = collateralBalance[msg.sender];
    uint256 existingDebt = debtBalance[msg.sender];

    uint256 maxBorrow = (collateral * LTV) / 100;

    if (existingDebt + amount > maxBorrow) {
        revert InsufficientCollateral();
    }

    if(stableToken.balanceOf(address(this)) < amount){
        revert InsufficientLiquidity();
    }

    //update state
    debtBalance[msg.sender] += amount;
    totalBorrows+= amount;
    lastBorrowTimestamp[msg.sender] = block.timestamp;

    //check health after state update
    if (getHealthFactor(msg.sender) < PRECISION){
        revert HealthFactorTooLow();
    }

    stableToken.safeTransfer(msg.sender, amount);
    emit Borrowed(msg.sender, amount);




}

/*
    liquidate()

    Allows anyone to repay part of an unhealthy loan
    and receive collateral plus bonus.
*/
function liquidate(address user, uint256 repayAmount) external nonReentrant{
    if (getHealthFactor(user)>= PRECISION){
        revert HealthFactorOk();
    }

    if(repayAmount == 0) revert AmountZero();

    uint256 userDebt = debtBalance[user];
    if (repayAmount > userDebt){
        repayAmount = userDebt;
    }

    stableToken.safeTransferFrom(msg.sender, address(this), repayAmount);
    debtBalance[user] -= repayAmount;
    totalBorrows -= repayAmount;
  uint256 collateralEquivalent =
        (repayAmount * (100 + LIQUIDATION_BONUS)) / 100;

    collateralBalance[user] -= collateralEquivalent;
    totalDeposits -= collateralEquivalent;

    collateralToken.safeTransfer(
        msg.sender,
        collateralEquivalent
    );

    emit Liquidated(msg.sender, user, repayAmount, collateralEquivalent);

}


/*
    accrueInterest()

    Updates borrower debt based on elapsed time.
*/
function accrueInterest(address user) public {
    uint256 lastTime = lastBorrowTimestamp[user];
    if (lastTime == 0) return;

    uint256 elapsed = block.timestamp - lastTime;
    if (elapsed == 0) return;

    uint256 debt = debtBalance[user];
    if (debt == 0) return;

    /*
        Correct interest math:

        interest =
        debt * annualRate * elapsed
        --------------------------------
        (365 days * 1e18)

        We multiply first, divide last.
    */

    uint256 interest =
        (debt * borrowRate * elapsed)
        / (365 days)
        / PRECISION;

    debtBalance[user] += interest;
    totalBorrows += interest;

    lastBorrowTimestamp[user] = block.timestamp;
}

}
