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
1. Configure opend RPC nodes of the chains you want to relay between (or use already configured by other people).
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
### Install Hermes by downloading
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
### Hermes Configuration
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
#### Let's create a `config.toml` with two chains
Example Configuration File fo Hermes https://hermes.informal.systems/example-config.html

Let's create our own config. Just run the command:
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
enabled = false

[mode.channels]
enabled = false

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















