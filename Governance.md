Cosmos chains have an on-chain governance mechanism for passing text proposals, changing consensus parameters, and spending funds from the community pool.
- [Params Wiki](https://hub.cosmos.network/main/governance/params-change/) - here you could learn that there are 8 modules active in the Cosmos Hub with parameters that may be altered via governance proposal.
- [Index of Governance parameters](https://hub.cosmos.network/main/governance/params-change/param-index.html) Here you could learn what parameters can be changed. For example [`gov` subspace](https://hub.cosmos.network/main/governance/params-change/Governance.html) 
- [Best Practices for Drafting a Proposal](https://hub.cosmos.network/main/governance/best-practices.html)
## How to
- Querying on-chain parameters
```
gaiad query params subspace <subspace_name> <key> --node <node_address> --chain-id <chain_id>
```
- Find out what are the current active proposals
```
gaiad query gov proposals
```
- How to vote `yes`. Change the `<number of proposal>`.
```
gaiad tx gov vote <number of proposal> yes --from=$(gaiad keys show $name_WALLET -a) --chain-id=$CHAIN_ID
```
