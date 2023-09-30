> This section is written for [Axelar TESTNET](https://github.com/AlexToTheSun/Validator_Activity/blob/main/Testnet-guides/Axelar). **But is suitable for all Cosmos network nodes.**
The blockchain grows in size over time. The filling rate of an SSD depends on the block production rate, the number of transactions in each block, the blockchain log settings, etc. 
Below are practical tips that will help you slow down the growth of the blockchain on servers 10 times.

## Universal One-line install script for all COSMOS chains:
```
wget -O disc-optimization.sh https://raw.githubusercontent.com/AlexToTheSun/Cosmos_Quick_Wiki/main/Scripts/Disk-Usage-Optimisation.sh && chmod +x disc-optimization.sh && ./disc-optimization.sh
```

# Editing `config.toml`
Let's start the setup by adjusting parameters of the file `$HOME/.axelar/config/config.toml`

### Indexing

The "Indexing" function is only needed by those who need to request transactions from a specific node. Most of the time this setting can be changed.
 
 You can just type the command:
 ```
sed -i.bak -e "s/^indexer *=.*/indexer = \""null"\"/" $HOME/.axelar/config/config.toml && \
sudo rm ~/.axelar/data/tx_index.db/*
 ```
 
 **Or manually.** Open file editing by nano:
 ```
 nano $HOME/.axelar/config/config.toml
 ```
Find a string `indexer = "info"` and change the parameter to "null":
```
indexer = "null"
```
Indexing files are stored in the `~/.axelar/data/tx_index.db/` directory. If you changed this parameter on a synchronized node that has already collected this information, then delete it with the command below:
```
sudo rm ~/.axelar/data/tx_index.db/*
```

### Logging

By default, the node state logging level is set to `info`, i.e. full display of all node information.

So `log_level = "info"` is useful when starting a node for the first time to make sure the node is working properly.

But after you understand that the node is working correctly and synchronizing, you can lower the log display level to `warn` (or even to `error`).

##### This parameter can be in one of two places:

1.  In the config file `$HOME/.axelar/config/config.toml`
> Before editing `config.toml`, make sure that there is no flag with logs in the axelar.service file ( just delete flag `--log_level`). Line for example:
`ExecStart=$HOME/go/bin/axelar start --log_level=info`

2. In the service file `/etc/systemd/system/axelar.service`. 
> In this case, check that in the file config.toml log line will be commented out:
> `# log_level = "info"`

It is important to understand: It doesn't matter where you change this parameter (in `axelar.service` or in `config.toml`), the main thing is that it should be in one place.

So, set the log parameter like this:
```
log_level = "warn"
```
Save and exit.

# Editing `app.toml`
The `app.toml` file is located at `$HOME/.axelar/config/app.toml`.

### State-sync snapshots
If we are not going to use the server for snapshots, then we need to set this parameter to zero by the command below:
```
sed -i.bak -e "s/^snapshot-keep-recent *=.*/snapshot-keep-recent = \""0"\"/" $HOME/.axelar/config/app.toml
```
**Or manually**. Go into the file
```
sudo nano $HOME/.axelar/config/app.toml
```
We go down to the end of the file and turn off snapshot intervals (change the value to 0). But in Axelar this parameter is already set to 0. Let's check:
```
snapshot-interval = 0
```

### Configure pruning
By commands:
```
sed -i.bak -e "s/^pruning *=.*/pruning = \""custom"\"/" $HOME/.axelar/config/app.toml
sed -i.bak -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \""100"\"/" $HOME/.axelar/config/app.toml
sed -i.bak -e "s/^pruning-keep-every *=.*/pruning-keep-every = \""0"\"/" $HOME/.axelar/config/app.toml
sed -i.bak -e "s/^pruning-interval *=.*/pruning-interval = \""10"\"/" $HOME/.axelar/config/app.toml
```
**Or manually**. Open `app.toml` with the nano editor:
```
nano $HOME/.axelar/config/app.toml
```
And we should bring the lines with pruning to this form:
```
pruning = "custom"
pruning-keep-recent = "100"
pruning-keep-every = "0"
pruning-interval = "10"
```

# Restart Axelar
```
sudo systemctl daemon-reload
sudo systemctl restart axelard
```
We have changed the Axelar config. Then for the changes to take effect, we need to restart it.

After restarting everything is work. Now the disk space will last 10 times longer.


