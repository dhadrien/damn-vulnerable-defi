const { ether } = require('@openzeppelin/test-helpers');
// I removed the use of openzeppelin contract object, to be able to use console.log
// Instead the buidler blugging from truffle will inject the web3 and contract objects
web3.eth.getAccounts().then((accounts) => {
  const DamnValuableToken = artifacts.require('DamnValuableToken');
  const TrusterLenderPool = artifacts.require('TrusterLenderPoolConsole');
  const TransfererAttacker = artifacts.require('TransfererAttackerConsole');
  
  const { expect } = require('chai');
  
  describe('[Challenge] Truster With console.log solidity statements', async function () {
      const TOKENS_IN_POOL = ether('1000000');
      const [deployer, attacker, ...otherAccounts] = accounts;
      before(async function () {
          /** SETUP SCENARIO */
          this.token = await DamnValuableToken.new({ from: deployer });
          this.pool = await TrusterLenderPool.new(this.token.address, { from: deployer });
  
          await this.token.transfer(this.pool.address, TOKENS_IN_POOL, { from: deployer });
  
          expect(
              await this.token.balanceOf(this.pool.address)
          ).to.be.bignumber.equal(TOKENS_IN_POOL);
  
          expect(
              await this.token.balanceOf(attacker)
          ).to.be.bignumber.equal('0');
      });
  
      it('Exploit', async function () {
          /** Borrow 0, approve attacker to spend tokens */
          this.attackerContract = await TransfererAttacker.new(this.token.address, this.pool.address, TOKENS_IN_POOL, {from: attacker});
      });
  
      after(async function () {
          /** SUCCESS CONDITIONS */
          expect(
              await this.token.balanceOf(attacker)
          ).to.be.bignumber.equal(TOKENS_IN_POOL);        
          expect(
              await this.token.balanceOf(this.pool.address)
          ).to.be.bignumber.equal('0');
      });
  });  
});


