If you send [unbond](https://docs.cosmos.network/master/modules/staking/09_client.html#unbond) delegation transaction:
```
simd tx staking unbond [validator-addr] [amount] [flags]
```
Here is what happens when you complete unbond transaction: [[State Transitions](https://docs.cosmos.network/master/modules/staking/02_state_transitions.html#bonded-to-unbonding)]

### How to cancel unbond
If the unbonding period has not yet passed, and you urgently need to delegate tokens to the validator, you shoud send [cancel unbond delegation](https://docs.cosmos.network/master/modules/staking/09_client.html#cancel-unbond):
```
simd tx staking cancel-unbond [validator-addr] [amount] [creation-height]
```
