Cosmovisor is designed to be used as a wrapper for a Cosmos SDK app. It is a small process manager for Cosmos SDK application binaries that monitors the governance module for incoming chain upgrade proposals.
> Note: Cosmovisor requires that the system administrator place all relevant binaries on disk before the upgrade happens.
> ❗️ The auto-download **[is not recommend option](https://github.com/cosmos/cosmos-sdk/tree/main/cosmovisor#auto-download)** but it could be enabled!
   
### What the update process looks like using cosmovisor (without auto-download)
1️⃣ We already have **Cosmovisor** and a **Cosmos SDK app** installed and configured.

2️⃣ The `system administrator` keeps an eye on the need to update the Cosmos SDK app. Most often this information comes from:
  - Announcement channel in the discord, where where the team publishes the number of the block on which you need to update + a link to the relevant binaries.
  -  A governance proposal is being created to upgrade the network.

3️⃣ `Sysadmin` build the new version app' binary.

4️⃣ `Sysadmin` create the folder for the upgrade binary and copy new app' binary there.

5️⃣ Done. The `cosmovisor` will do the rest on its own.
  -  cosmovisor is polling the `$DAEMON_HOME/data/upgrade-info.json` file for new upgrade instructions when an upgrade is detected and the blockchain reaches the upgrade height. [More info](https://github.com/cosmos/cosmos-sdk/tree/main/cosmovisor#detecting-upgrades).
  -  Cosmovisor updates bynary and restart the network.
## Documetnation
- https://github.com/cosmos/cosmos-sdk/tree/main/cosmovisor

## Installation
Here we will walk through the installation process step by step. The update process will be discussed in the next paragraphs.
- Update and install dependencies
- Install cosmovisor v0.1.0 version
- Install Cosmos SDK application
- Let's set variables for cosmovisor
- Start cosmovisor by service
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
### Let's set variables for cosmovisor
```
export DAEMON_HOME=$HOME/.tgrade
export DAEMON_NAME=tgrade
export DAEMON_ALLOW_DOWNLOAD_BINARIES=true
export DAEMON_RESTART_AFTER_UPGRADE=true
export UNSAFE_SKIP_BACKUP=false
source ~/.bash_profile
echo $DAEMON_NAME
```
Create a folder for cosmovisor
```
mkdir -p ~/.tgrade/cosmovisor/genesis/bin/
```
Copy to the folder out bynary file
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
ExecStart=$(which cosmovisor) start
Restart=always
RestartSec=3
LimitNOFILE=65535

Environment="DAEMON_HOME=$HOME/.tgrade"
Environment="DAEMON_NAME=tgrade"
Environment="DAEMON_ALLOW_DOWNLOAD_BINARIES=true"
Environment="DAEMON_RESTART_AFTER_UPGRADE=true"
Environment="UNSAFE_SKIP_BACKUP=false"

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

