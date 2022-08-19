Cosmovisor is designed to be used as a wrapper for a Cosmos SDK app. It is a small process manager for Cosmos SDK application binaries that monitors the governance module for incoming chain upgrade proposals.
> Note: Cosmovisor requires that the system administrator place all relevant binaries on disk before the upgrade happens.
> ❗️ The auto-download **[is not recommend option](https://github.com/cosmos/cosmos-sdk/tree/main/cosmovisor#auto-download)** but it could be enabled!
   
### What the update process looks like using cosmovisor (without auto-download)
1️⃣ We already have **Cosmovisor** and a **Cosmos SDK app** installed and configured.

2️⃣ The `system administrator` keeps an eye on the need to update the Cosmos SDK app. Most often this information comes from:
  - Announcement channel in the discord, where the team publishes the number of the block on which you need to update + a link to the relevant binaries.
  -  A governance proposal is being created to upgrade the network.

3️⃣ `Sysadmin` build the new version app' binary.

4️⃣ `Sysadmin` create the folder for the upgrade binary and copy new app' binary there.

5️⃣ Done. The `cosmovisor` will do the rest on its own.
  -  cosmovisor is polling the `$DAEMON_HOME/data/upgrade-info.json` file for new upgrade instructions when an upgrade is detected and the blockchain reaches the upgrade height. [More info](https://github.com/cosmos/cosmos-sdk/tree/main/cosmovisor#detecting-upgrades).
  -  Cosmovisor updates bynary and restart the network.
  -  Don't forget, afte upgrade process is finished, to copy new bynary file from `$HOME/.tgrade/cosmovisor/upgrades/<name>/bin/tgrade` to an executable path `/usr/local/bin`
## Documetnation
- https://github.com/cosmos/cosmos-sdk/tree/main/cosmovisor

## Installation
Here we will walk through the installation process step by step. The update process will be discussed in the next paragraphs.
- [Update and install dependencies](https://github.com/AlexToTheSun/Cosmos_Quick_Wiki/blob/main/Cosmovisor.md#update-and-install-dependencies)
- [Install cosmovisor](https://github.com/AlexToTheSun/Cosmos_Quick_Wiki/blob/main/Cosmovisor.md#install-cosmovisor-v010-version)
- [Install Cosmos SDK application](https://github.com/AlexToTheSun/Cosmos_Quick_Wiki/blob/main/Cosmovisor.md#install-cosmos-sdk-application)
- [Setting up variables for cosmovisor](https://github.com/AlexToTheSun/Cosmos_Quick_Wiki/blob/main/Cosmovisor.md#lets-set-variables-for-cosmovisor)
- [Start cosmovisor by service](https://github.com/AlexToTheSun/Cosmos_Quick_Wiki/blob/main/Cosmovisor.md#start-cosmovisor-by-service)
### Update and install dependencies
Update and install dependencies
```
sudo apt update && sudo apt upgrade -y
sudo apt install nano mc wget git build-essential jq make -y
```
Install GO
```
wget -O go1.18.3.linux-amd64.tar.gz https://go.dev/dl/go1.18.3.linux-amd64.tar.gz
rm -rf /usr/local/go && tar -C /usr/local -xzf go1.18.3.linux-amd64.tar.gz && rm go1.18.3.linux-amd64.tar.gz

cat <<'EOF' >> $HOME/.bash_profile
export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export GO111MODULE=on
export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin
EOF

. $HOME/.bash_profile
cp /usr/local/go/bin/go /usr/bin
go version
# go version go1.18.3 linux/amd64
```
### Install cosmovisor v0.1.0 version
```
go install github.com/cosmos/cosmos-sdk/cosmovisor/cmd/cosmovisor@v0.1.0

cd $HOME/go/bin/cosmovisor /usr/local/bin
```
Or you could install from source, see [here](https://github.com/cosmos/cosmos-sdk/tree/main/cosmovisor#installation).

### Install Cosmos SDK application
For example we will build Tgrade.
```
rm -rf /root/tgrade
git clone https://github.com/confio/tgrade
cd tgrade
git checkout v1.0.1
# Run GO install and build for the upcoming binary
make build
# Move the binary to an executable path
mv build/tgrade /usr/local/bin
tgrade version
```
### Setting up Environment Variables for cosmovisor
Cosmovisor relies on the following environmental variables to work properly (see [here for more info](https://github.com/cosmos/cosmos-sdk/tree/main/cosmovisor#command-line-arguments-and-environment-variables)):
- `DAEMON_HOME` - is the location where upgrade binaries should be kept (e.g. $HOME/.tgrade)
- `DAEMON_NAME` - is the name of the binary itself (e.g. tgrade)

- `DAEMON_ALLOW_DOWNLOAD_BINARIES` - (defaults to `false`)  if set to `true`, will enable auto-downloading of new binaries (for security reasons, this is intended for full nodes rather than validators).
- `DAEMON_RESTART_AFTER_UPGRADE` - (default = `true`) restarts the Cosmos SDK app. If `false`, cosmovisor stops running after an upgrade and requires the system administrator to manually restart it.
- `UNSAFE_SKIP_BACKUP` - (defaults to `false`) upgrades with performing backs up the data before trying the upgrade. The default value of `false` is useful and recommended in case of failures and when a backup needed to rollback.  If set to `true`, upgrades directly without performing a backup (it is usefull if you don't have enough free disk space). 

- `DAEMON_RESTART_DELAY` - (default `none`) allow a node operator to define a delay between the node halt (for upgrade) and backup by the specified time.
- `DAEMON_POLL_INTERVAL` - (default `300` milliseconds)
- `DAEMON_DATA_BACKUP_DIR`  - option to set a custom backup directory. By default is `DAEMON_HOME`
- `DAEMON_PREUPGRADE_MAX_RETRIES` -  (defaults to `0`) The maximum number of failed times to call `pre-upgrade`. After the maximum number of retries, cosmovisor fails the upgrade.
```
export DAEMON_HOME=$HOME/.tgrade
export DAEMON_NAME=tgrade
export DAEMON_RESTART_AFTER_UPGRADE=true
export UNSAFE_SKIP_BACKUP=true
source ~/.bash_profile
echo $DAEMON_NAME
```
Create a folder for the genesis `tgrade` binary for cosmovisor
```
mkdir -p ~/.tgrade/cosmovisor/genesis/bin/
```
Copy the binary file to сreated folder
```
cp $(which tgrade) ~/.tgrade/cosmovisor/genesis/bin/
```
Now we can check the cosmovisor version
```
cosmovisor version
# or
strings $(which cosmovisor) | egrep -e "mod\s+github.com/cosmos/cosmos-sdk/cosmovisor"
```
![image](https://user-images.githubusercontent.com/30211801/185399388-5f7a558e-efa8-4635-8643-cab7acc475ed.png)

### Start cosmovisor by service
Create a service file
```
sudo tee /etc/systemd/system/tgrade.service > /dev/null <<EOF  
[Unit]
Description=Tgrade Full Node
After=network-online.target

[Service]
User=$USER
ExecStart=$(which cosmovisor) run start
Restart=always
RestartSec=3
LimitNOFILE=65535

Environment="DAEMON_HOME=$HOME/.tgrade"
Environment="DAEMON_NAME=tgrade"
Environment="DAEMON_RESTART_AFTER_UPGRADE=true"
Environment="UNSAFE_SKIP_BACKUP=true"

[Install]
WantedBy=multi-user.target
EOF
```
Start
```
sudo systemctl daemon-reload \
&& sudo systemctl enable tgrade \
&& sudo systemctl restart tgrade \
&& sudo journalctl -u tgrade -f --no-hostname -o cat
```

## Upgrading the binary

Build the new binary:
```
rm -rf /root/tgrade
git clone https://github.com/confio/tgrade && cd tgrade
git checkout v2.0.0
make build
```
 Create a folder for the upgrade binary and copy `tgrade` binary here:
```
mkdir -p $HOME/.tgrade/cosmovisor/upgrades/v2.0.0/bin
mv  $HOME/tgrade/build/tgrade $HOME/.tgrade/cosmovisor/upgrades/v2.0.0/bin
```
 Check the version for upgrading
 ```
 $HOME/.tgrade/cosmovisor/upgrades/v2.0.0/bin/tgrade version
 ```
 🎉 You are ready to upgrade. It is advisable to control the process, in case there are errors during the update process. 
 
 After an upgrade succesfully ends, **copy new binary to an executable path**:
 ```
cp $HOME/.tgrade/cosmovisor/upgrades/v2.0.0/bin/tgrade /usr/local/bin
 ```
You also can copy the binary to /usr/local/bin **before upgrade**, but in this case don't restart the app.

