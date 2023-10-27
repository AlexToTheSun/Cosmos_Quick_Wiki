#!/bin/bash
function send_telegram_message() {
  local message="$1"
  curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_API_TOKEN/sendMessage" \
    -d chat_id="$TELEGRAM_CHAT_ID" \
    -d text="$message" 2>&1 1>/dev/null 
}

# Add variables
. ~/.bash_profile
if [ ! $TELEGRAM_API_TOKEN ]; then
  read -p 'Your TELEGRAM API TOKEN. Example "826405938:djhNkduNekj4njmfjJJJDHkjdsJ732349kjdfD": ' TELEGRAM_API_TOKEN
  echo 'export TELEGRAM_API_TOKEN='$TELEGRAM_API_TOKEN >> $HOME/.bash_profile
  . ~/.bash_profile
fi

if [ ! $TELEGRAM_CHAT_ID  ]; then
  read -p 'Your TELEGRAM CHAT ID. Example "947265947": ' TELEGRAM_CHAT_ID
  echo 'export TELEGRAM_CHAT_ID='$TELEGRAM_CHAT_ID >> $HOME/.bash_profile
  . ~/.bash_profile
fi

read -p 'Path to your current binary. Example "/usr/local/bin/haqqd": ' current_binary
read -p 'Path to your new binary. Example "$HOME/go/bin/haqqd": ' new_binary
read -p "Height of the last block, after that a chain will be stopped: " stop_height
read -p "Name of your cosmos blockchain' service file: " service_name
read -p "Your node' rpc port: " rpc_port

# Checking variables
echo $current_binary \
&& $new_binary version \
&& curl -s localhost:$rpc_port/status | grep -E 'network|latest_block_height' \
&& service $service_name status | grep -E 'loaded|active'
sleep 3
if [ ! $current_binary ] || [ ! $current_binary ] || [ ! $current_binary ] || [ ! $current_binary ] ; then
	echo ' Type all of the necessary variables'
	exit
else
	echo 'All variables are set!'
fi

# Upgrading of the binary file
for ((;;))
do
    height=$(curl -s localhost:$rpc_port/status | jq -r .result.sync_info.latest_block_height)
    if ! [ $height -eq $stop_height ]
    then
      echo $height
      send_telegram_message "$[$stop_height-$height] blocks left"
    else
      systemctl stop $service_name
      mv $new_binary $current_binary
      systemctl restart $service_name
      echo 'Stopping, Changing the binary and Restarting done'
      send_telegram_message "!!!About ${service_name}: work is done. Stop, Change binary file, Restart. Please, check!"
      breack
    fi
      sleep 4
done
