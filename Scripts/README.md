## Running update.sh script
Only for service file users (cosmos chains).

Download
```
cd && wget -O /usr/local/bin/update.sh https://raw.githubusercontent.com/AlexToTheSun/Cosmos_Quick_Wiki/main/Scripts/update.sh && chmod +x /usr/local/bin/update.sh
```
Run
```
update.sh
```
Preparation:
- Download/build the binary on your server.

What this script does:
- Checks the current height of the block, and acts upon reaching the last block.
- Stops, replaces the binary file, starts again.
- Sends in telegram. notification of work done and request to check.
