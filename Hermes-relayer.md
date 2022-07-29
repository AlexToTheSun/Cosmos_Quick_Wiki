## Documetnation
- https://github.com/informalsystems/ibc-rs
- https://hermes.informal.systems/
- [An Overview of The Interblockchain Communication Protocol](https://arxiv.org/pdf/2006.15918.pdf)

## Table of contents
0. Relaying overwiew
1. Configure opend RPC nodes and Fund keys
2. Install and configure Hermes
3.1 create-client
3.2 client state
3.3 update-client
4.1 conn-init
4.2 conn-try
4.3 conn-ack
4.4 conn-confirm
4.5 connection end
5.1 chan-open-init
5.2 chan-open-try
5.3 chan-open-ack
5.4 chan-open-confirm
5.5 

# 0.Relaying overwiew

#### What is Hermes?
As we could see, [Hermes](https://hermes.informal.systems/relayer.html) is a an open-source Rust implementation of a relayer for the Inter-Blockchain Communication protocol (IBC).

Hermes is a relayer CLI (i.e., a binary). It is not the same as the relayer core library (that is the crate called [ibc-relayer](https://crates.io/crates/ibc-relayer)).

An IBC relayer is an off-chain process responsible for relaying IBC datagrams between any two Cosmos chains.

#### How does an IBC relayer work?
1. scanning chain states
2. building transactions based on these states
3. submitting the transactions to the chains involved in the network.

#### So what we need to relaying?
1. Configure opend RPC nodes (or use already configured by other people) of the chains you want to relay between.
2. Fund keys of the chains you want to relay between for paying relayer fees.
3. Configure Hermes.

# Configure opend RPC nodes and Fund keys
We will configure Hermes to operate between **StaFiHub** and **SEI Network** in testnets.
## SEI Network. Configure opend RPC node.
Now (29 july 2022) current testnet chain for SEI Network is:
- `atlantic-1`
1. Run your own SEI RPC node [[Instructions](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet-guides/SEI-testnet-devnet/SEI_atlantic-1.md#instructions)]

You should wait until status synchronization is true. No need to create a validator!
2. Configure node for using it by Hermes:
```
sed -i.bak -e "s/^indexer *=.*/indexer = \""kv"\"/" $HOME/.sei/config/config.toml
sed -i.bak -E "s|^(pex[[:space:]]+=[[:space:]]+).*$|\1true|" $HOME/.sei/config/config.toml
sed -i '/\[grpc\]/{:a;n;/enabled/s/false/true/;Ta};/\[api\]/{:a;n;/enable/s/false/true/;Ta;}' $HOME/.sei/config/app.toml
sed -i.bak -e "s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://0.0.0.0:26657\"%" $HOME/.sei/config/config.toml
sudo systemctl restart seid
```
#### Check settings
Open in nano`$HOME/.sei/config/config.toml` and make shure that `config.toml` contens lines:
```
#######################################################
###       RPC Server Configuration Options          ###
#######################################################
[rpc]
...
laddr = "tcp://0.0.0.0:26657"
...
...

#######################################################
###           P2P Configuration Options             ###
#######################################################
[p2p]
...
# Set true to enable the peer-exchange reactor
pex = true
...
...
```
Open in nano`$HOME/.sei/config/app.toml` and make shure that `app.toml` contens the lines:
```
###############################################################################
###                           gRPC Configuration                            ###
###############################################################################

[grpc]

# Enable defines if the gRPC server should be enabled.
enable = true

# Address defines the gRPC server address to bind to.
address = "0.0.0.0:9090"
```
#### Fund your SEI key.
Use SEI testnet faucet for funding your wallet that you will use for Hermes. It will be needed for paying relayer fees.

## StaFiHub. Configure opend RPC node.
Now (29 july 2022) current testnet chain for StaFiHub is:
- `stafihub-public-testnet-3`
1. Run your own StaFiHub RPC node [[Instructions](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet-guides/StafiHub/Basic-Installation.md#install-stafihub)]

You should wait until status synchronization is true. No need to create a validator!
2. Configure node for using it by Hermes:
```
sed -i.bak -e "s/^indexer *=.*/indexer = \""kv"\"/" $HOME/.stafihub/config/config.toml
sed -i.bak -E "s|^(pex[[:space:]]+=[[:space:]]+).*$|\1true|" $HOME/.stafihub/config/config.toml
sed -i '/\[grpc\]/{:a;n;/enabled/s/false/true/;Ta};/\[api\]/{:a;n;/enable/s/false/true/;Ta;}' $HOME/.stafihub/config/app.toml
sed -i.bak -e "s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://0.0.0.0:26657\"%" $HOME/.stafihub/config/config.toml
sudo systemctl restart stafihubd
```
#### Check settings
Open in nano`$HOME/.stafihub/config/config.toml` and make shure that `config.toml` contens lines:
```
#######################################################
###       RPC Server Configuration Options          ###
#######################################################
[rpc]
...
laddr = "tcp://0.0.0.0:26657"
...
...

#######################################################
###           P2P Configuration Options             ###
#######################################################
[p2p]
...
# Set true to enable the peer-exchange reactor
pex = true
...
...
```
Open in nano`$HOME/.stafihub/config/app.toml` and make shure that `app.toml` contens the lines:
```
###############################################################################
###                           gRPC Configuration                            ###
###############################################################################

[grpc]

# Enable defines if the gRPC server should be enabled.
enable = true

# Address defines the gRPC server address to bind to.
address = "0.0.0.0:9090"
```
#### Fund your StaFiHub key.
Use SEI testnet faucet for funding your wallet that you will use for Hermes. It will be needed for paying relayer fees.

# Install and configure Hermes
This step could be done on the separate server, or on the server that you already installed one of the chains.
## Install Hermes by downloading
Official instruction is [here](https://hermes.informal.systems/installation.html)
```
sudo apt install unzip -y
mkdir $HOME/.hermes
wget https://github.com/informalsystems/ibc-rs/releases/download/v1.0.0-rc.1/hermes-v1.0.0-rc.1-x86_64-unknown-linux-gnu.tar.gz
mkdir -p $HOME/.hermes/bin
tar -C $HOME/.hermes/bin/ -vxzf hermes-v1.0.0-rc.1-x86_64-unknown-linux-gnu.tar.gz
echo 'export PATH="$HOME/.hermes/bin:$PATH"' >> $HOME/.bash_profile
source $HOME/.bash_profile
```
Run `hermes` (without any additional parameters) and you should see the usage and help information:
```
hermes 1.0.0-rc.0+b80bcea
Informal Systems <hello@informal.systems>
  Hermes is an IBC Relayer written in Rust

USAGE:
    hermes [OPTIONS] [SUBCOMMAND]

OPTIONS:
        --config <CONFIG>    Path to configuration file
    -h, --help               Print help information
        --json               Enable JSON output
    -V, --version            Print version information

SUBCOMMANDS:
    clear           Clear objects, such as outstanding packets on a channel
    config          Validate Hermes configuration file
    create          Create objects (client, connection, or channel) on chains
    health-check    Performs a health check of all chains in the the config
    help            Print this message or the help of the given subcommand(s)
    keys            Manage keys in the relayer for each chain
    listen          Listen to and display IBC events emitted by a chain
    misbehaviour    Listen to client update IBC events and handles misbehaviour
    query           Query objects from the chain
    start           Start the relayer in multi-chain mode
    tx              Create and send IBC transactions
    update          Update objects (clients) on chains
    upgrade         Upgrade objects (clients) after chain upgrade
    completions     Generate auto-complete scripts for different shells
```
## Hermes Configuration
First of all let's set the variables that will be needed to create the Hermes config file.  
For each chains we need the parameters below:
- `chain_id` - current chain ID for the network 
- `rpc_addr` - the RPC `address` and `port` where the chain RPC server listens on.
- `grpc_addr` - the GRPC `address` and `port` where the chain GRPC server listens on.
- `websocket_addr` - the WebSocket address and port where the chain WebSocket server
- `account_prefix` - the prefix used by the chain.
- `trusting_period` - `trusting_period=2/3*(unbonding period)`. It is the amount of time to be used as the light client trusting period.
- `denom`
- `max_tx_size` - the maximum size, in bytes, of each transaction that Hermes will submit.

Example Configuration File fo Hermes https://hermes.informal.systems/example-config.html
About config. TLS connection https://hermes.informal.systems/config.html#connecting-via-tls
#### For SEI network:
```
chain_id_SEI="atlantic-1"
rpc_addr_SEI="http://<sei_node_ip>:<sei_rpc_port>"
grpc_addr_SEI="http://<sei_node_ip>:<sei_grpc_port>"
websocket_addr_SEI="ws://<sei_node_ip>:<sei_rpc_port>/websocket"
account_prefix_SEI="sei"
trusting_period_SEI="7h"
denom_SEI="usei"
max_tx_size_SEI="2097152"
gas_price_SEI="0.001"
```
Example with standard ports:
```
chain_id_SEI="atlantic-1"
rpc_addr_SEI="http://23.54.11.07:26657"
grpc_addr_SEI="http://23.54.11.07:9090"
websocket_addr_SEI="ws://23.54.11.07:26657/websocket"
account_prefix_SEI="sei"
trusting_period_SEI="7h"
denom_SEI="usei"
max_tx_size_SEI="2097152"
gas_price_SEI="0.001"
```

#### For StaFiHub network:

```
chain_id_Stafihub="stafihub-public-testnet-3"
rpc_addr_Stafihub="http://<sei_node_ip>:<sei_rpc_port>"
grpc_addr_Stafihub="http://<sei_node_ip>:<sei_grpc_port>"
websocket_addr_Stafihub="ws://<sei_node_ip>:<sei_rpc_port>/websocket"
account_prefix_Stafihub="stafi"
trusting_period_Stafihub="16h"
denom_Stafihub="ufis"
max_tx_size_Stafihub="180000"
gas_price_Stafihub="0.01"
```
Example with standard ports:
```
chain_id_Stafihub="stafihub-public-testnet-3"
rpc_addr_Stafihub="http://32.45.11.70:26657"
grpc_addr_Stafihub="http://32.45.11.70:9090"
websocket_addr_Stafihub="ws://32.45.11.70:26657/websocket"
account_prefix_Stafihub="stafi"
trusting_period_Stafihub="16h"
denom_Stafihub="ufis"
max_tx_size_Stafihub="180000"
gas_price_Stafihub="0.01"
```
#### Specify relayer name
```
relayer_name="<your_relayer_name>"
```
### Let's create a `config.toml` with two chains
- Example of config - https://hermes.informal.systems/example-config.html
- Abling to handle channel handshake and packet events - https://hermes.informal.systems/commands/relaying/handshakes.html

Let's create our own config. We will configure our Hermes to be able handles [channel and packet messages](https://hermes.informal.systems/commands/relaying/handshakes.html)

Just run the command:
```
sudo tee $HOME/.hermes/config.toml > /dev/null <<EOF
[global]
log_level = 'info'

[mode]

[mode.clients]
enabled = true
refresh = true
misbehaviour = true

[mode.connections]
enabled = true

[mode.channels]
enabled = true

[mode.packets]
enabled = true
clear_interval = 100
clear_on_start = true
tx_confirmation = true

[rest]
enabled = true
host = '127.0.0.1'
port = 3000

[telemetry]
enabled = true
host = '127.0.0.1'
port = 3001

[[chains]]
### CHAIN_SEI ###
id = '${chain_id_SEI}'
rpc_addr = '${rpc_addr_SEI}'
grpc_addr = '${grpc_addr_SEI}'
websocket_addr = '${websocket_addr_SEI}'
rpc_timeout = '10s'
account_prefix = '${account_prefix_SEI}'
key_name = 'wallet'
address_type = { derivation = 'cosmos' }
store_prefix = 'ibc'
default_gas = 100000
max_gas = 600000
gas_price = { price = '${gas_price_SEI}', denom = '${denom_SEI}' }
gas_multiplier = 1.1
max_msg_num = 30
max_tx_size = '${max_tx_size_SEI}'
clock_drift = '5s'
max_block_time = '30s'
trusting_period = '${trusting_period_SEI}'
trust_threshold = { numerator = '1', denominator = '3' }
memo_prefix = '${relayer_name} Relayer'

[[chains]]
### CHAIN_StaFiHub ###
id = '${chain_id_Stafihub}'
rpc_addr = '${rpc_addr_Stafihub}'
grpc_addr = '${grpc_addr_Stafihub}'
websocket_addr = '${websocket_addr_Stafihub}'
rpc_timeout = '10s'
account_prefix = '${account_prefix_Stafihub}'
key_name = 'wallet'
address_type = { derivation = 'cosmos' }
store_prefix = 'ibc'
default_gas = 100000
max_gas = 600000
gas_price = { price = '${gas_price_Stafihub}', denom = '${denom_Stafihub}' }
gas_multiplier = 1.1
max_msg_num = 30
max_tx_size = '${max_tx_size_Stafihub}'
clock_drift = '5s'
max_block_time = '30s'
trusting_period = '${trusting_period_Stafihub}'
trust_threshold = { numerator = '1', denominator = '3' }
memo_prefix = '${relayer_name} Relayer'
EOF
```
#### Performs a health check of all chains in the the config
After you create a config, checking is required:
```
hermes health-check
```
At this stage, problems may arise, and it is very important for us to solve them. After that, let's move on to the next steps.

## Adding private keys
- Official instruction of Adding private keys - https://hermes.informal.systems/commands/keys/index.html
- Transactions - https://hermes.informal.systems/commands/tx/index.html

You need to add a private key for each chain. After that Hermes will be enabled to submit [transactions](https://hermes.informal.systems/commands/tx/index.html).

In our example you should add SEI and StafiHub keys. The `key_name` parameter from Hermes `config.toml`, is the name of the key that will be added after restoring Keys.

```
MNEMONIC_SEI='speed rival market sure decade call silly flush derive story state menu inflict catalog habit swallow anxiety lumber siege fuel engage kite dad harsh'

MNEMONIC_STAFIHUB='speed rival market sure decade call silly flush derive story state menu inflict catalog habit swallow anxiety lumber siege fuel engage kite dad harsh'

sudo tee $HOME/.hermes/${chain_id_SEI}.mnemonic > /dev/null <<EOF
${MNEMONIC_SEI}
EOF
sudo tee $HOME/.hermes/${chain_id_Stafihub}.mnemonic > /dev/null <<EOF
${MNEMONIC_STAFIHUB}
EOF
hermes keys add --chain ${chain_id_SEI} --mnemonic-file $HOME/.hermes/${chain_id_SEI}.mnemonic
hermes keys add --chain ${chain_id_Stafihub} --mnemonic-file $HOME/.hermes/${chain_id_Stafihub}.mnemonic
```
## Clients. Connections. Channels.
#### Identifiers
First make sure you followed the steps in the [start the local chains](https://hermes.informal.systems/tutorials/local-chains/start.html) and [Identifiers](https://hermes.informal.systems/tutorials/local-chains/identifiers.html) section


#### 1 Identifiers
https://hermes.informal.systems/tutorials/local-chains/identifiers.html

Create your `sei-->stafihub` client
```
hermes tx raw create-client --host-chain atlantic-1 --reference-chain stafihub-public-testnet-3
```
![Снимок экрана от 2022-07-29 21-32-43](https://user-images.githubusercontent.com/30211801/181814003-7812b4f0-c2e1-4ff8-a5cf-b1c450727823.png)
Query `sei-->stafihub` client, with your client_id (in the transaction below there will be my information just for examples)
```
hermes query client state --chain atlantic-1 --client 07-tendermint-613
```
Create your `stafihub-->sei` client
```
hermes tx raw create-client --host-chain stafihub-public-testnet-3 --reference-chain atlantic-1
```
![Снимок экрана от 2022-07-29 21-38-16](https://user-images.githubusercontent.com/30211801/181814741-8dd9b5ab-e6a1-4342-bf70-ef413173d274.png)
Query `stafihub-->sei` client, with your client_id
```
hermes query client state --chain stafihub-public-testnet-3 --client 07-tendermint-44
```
Update your `sei-->stafihub` client
```
hermes tx raw update-client --host-chain atlantic-1 --client 07-tendermint-613
```
![Снимок экрана от 2022-07-29 21-43-57](https://user-images.githubusercontent.com/30211801/181815590-d5161b16-bac2-436d-9d63-5ea240738cbb.png)

Update your `stafihub-->sei` client
```
hermes tx raw update-client --host-chain stafihub-public-testnet-3 --client 07-tendermint-44
```
![Снимок экрана от 2022-07-29 21-45-00](https://user-images.githubusercontent.com/30211801/181815752-36e2edf8-71cb-4229-9b82-ca0cb2f88719.png)

#### 2. Connection Handshake
Create `sei-->stafihub` connection 
```
hermes tx raw conn-init --dst-chain atlantic-1 --src-chain stafihub-public-testnet-3 --dst-client 07-tendermint-613 --src-client 07-tendermint-44
```
![Снимок экрана от 2022-07-29 21-46-49](https://user-images.githubusercontent.com/30211801/181816033-c24255cb-a17d-4cab-b1c6-053f75b7e5f7.png)
here we are : `connection-287`

Create `stafihub-->sei` connection 
```
hermes tx raw conn-init --dst-chain stafihub-public-testnet-3 --src-chain atlantic-1 --dst-client 07-tendermint-44 --src-client 07-tendermint-613
```
![Снимок экрана от 2022-07-29 21-49-00](https://user-images.githubusercontent.com/30211801/181816324-7347cdfa-4abd-4487-a6fc-f3a4d6deb29f.png)
here we are : `connection-31`

Conn-try `stafihub-->sei`
```
hermes tx raw conn-try --dst-chain atlantic-1 --src-chain stafihub-public-testnet-3 --dst-client 07-tendermint-613 --src-client 07-tendermint-44 --src-conn connection-31
```
![Снимок экрана от 2022-07-29 22-01-53](https://user-images.githubusercontent.com/30211801/181818302-5d33b97d-88d0-4712-afcf-95c910ef61c1.png)

Strange. There is an Error, but transection [46D553C9A1E3B4A08BCC4F13F8DFEAF9275C2A13F5F4568BC4FD6EDD4710DDFD](https://testnet-explorer.stafihub.io/stafi-hub-testnet/tx/46D553C9A1E3B4A08BCC4F13F8DFEAF9275C2A13F5F4568BC4FD6EDD4710DDFD) is successful.   
Log of error:
```
2022-07-29T17:53:30.815480Z  INFO ThreadId(01) using default configuration from '/root/.hermes/config.toml'
2022-07-29T17:53:33.144783Z  INFO ThreadId(14) wait_for_block_commits: waiting for commit of tx hashes(s) 46D553C9A1E3B4A08BCC4F13F8DFEAF9275C2A13F5F4568BC4FD6EDD4710DDFD id=stafihub-public-testnet-3
Error: connection error: failed to build connection proofs: bad connection state
```
Conn-try `sei-->stafihub`
```
hermes tx raw conn-try --dst-chain stafihub-public-testnet-3 --src-chain atlantic-1 --dst-client 07-tendermint-44 --src-client 07-tendermint-613 --src-conn connection-287
```
There is an Error, but transection [3A9A9EF8C07D95AC4BAE25619975BE92FF18C87DF72A27566615414B03E88C59](https://sei.explorers.guru/transaction/3A9A9EF8C07D95AC4BAE25619975BE92FF18C87DF72A27566615414B03E88C59) is successful.   
Log of error:
```
2022-07-29T18:03:14.460739Z  INFO ThreadId(01) using default configuration from '/root/.hermes/config.toml'
2022-07-29T18:03:20.465310Z  INFO ThreadId(14) wait_for_block_commits: waiting for commit of tx hashes(s) 3A9A9EF8C07D95AC4BAE25619975BE92FF18C87DF72A27566615414B03E88C59 id=atlantic-1
Error: connection error: failed to build connection proofs: bad connection state
```

Init channel
```
hermes tx raw chan-open-init --dst-chain stafihub-public-testnet-3 --src-chain atlantic-1 --dst-conn connection-31 --dst-port transfer --src-port transfer --order UNORDERED
```
![Снимок экрана от 2022-07-29 22-51-37](https://user-images.githubusercontent.com/30211801/181825652-b1379991-f210-4e5f-9faf-31c190be8c54.png)
Here is the `channel-26` created

```
hermes tx raw chan-open-init --dst-chain atlantic-1 --src-chain stafihub-public-testnet-3 --dst-conn connection-287 --dst-port transfer --src-port transfer --order UNORDERED
```
![Снимок экрана от 2022-07-29 22-53-29](https://user-images.githubusercontent.com/30211801/181825926-0b65fd6f-2f5a-4ffd-81a6-48d3787668a1.png)
Here is the `channel-264` created


```
hermes tx raw conn-ack --dst-chain atlantic-1 --src-chain stafihub-public-testnet-3 --dst-client 07-tendermint-613 --src-client 07-tendermint-44 --dst-conn connection-287 --src-conn connection-31
```
![Снимок экрана от 2022-07-29 23-02-24](https://user-images.githubusercontent.com/30211801/181827258-beefdb46-4767-4364-9c52-a29cc8617891.png)
Logs of command:
```
root@nb3c732:~# hermes tx raw chan-open-try --dst-chain atlantic-1 --src-chain stafihub-public-testnet-3 --dst-conn connection-287 --dst-port transfer --src-port transfer --src-chan channel-26
2022-07-29T18:56:53.959813Z  INFO ThreadId(01) using default configuration from '/root/.hermes/config.toml'
2022-07-29T18:56:54.214083Z  INFO ThreadId(01) Message ChanOpenTry: Channel { ordering: Unordered, a_side: ChannelSide { chain: BaseChainHandle { chain_id: ChainId { id: "stafihub-public-testnet-3", version: 3 }, runtime_sender: Sender { .. } }, client_id: ClientId("07-tendermint-0"), connection_id: ConnectionId("connection-0"), port_id: PortId("transfer"), channel_id: Some(ChannelId("channel-26")), version: None }, b_side: ChannelSide { chain: BaseChainHandle { chain_id: ChainId { id: "atlantic-1", version: 1 }, runtime_sender: Sender { .. } }, client_id: ClientId("07-tendermint-613"), connection_id: ConnectionId("connection-287"), port_id: PortId("transfer"), channel_id: None, version: None }, connection_delay: 0ns }
2022-07-29T18:57:03.271639Z ERROR ThreadId(27) send_tx_with_account_sequence_retry{id=atlantic-1}:estimate_gas: failed to simulate tx. propagating error to caller: gRPC call failed with status: status: Unknown, message: "failed to execute message; message index: 1: channel handshake open try failed: channel fields mismatch previous channel fields: invalid channel", details: [], metadata: MetadataMap { headers: {"content-type": "application/grpc", "x-cosmos-block-height": "1469499"} }
Error: channel error: failed during a transaction submission step to chain 'atlantic-1': gRPC call failed with status: status: Unknown, message: "failed to execute message; message index: 1: channel handshake open try failed: channel fields mismatch previous channel fields: invalid channel", details: [], metadata: MetadataMap { headers: {"content-type": "application/grpc", "x-cosmos-block-height": "1469499"} }
```
