#!/bin/bash
# Set variables
# Now here is Modules: 
# - Change the password,
# - Change the SSH port,
# - Firewall configuration (ufw)
# case: https://www.opennet.ru/docs/RUS/bash_scripting_guide/x5210.html
# case: https://routerus.com/bash-case-statement/
# bash stsenari s operatorami if:  https://g-soft.info/articles/2814/usloviya-v-stsenariyah-bash-operatory-if/
# Additionally:
# otritsanie !: https://g-soft.info/articles/7293/bash-proverit-pusta-li-peremennaya/
# https://www.opennet.ru/docs/RUS/bash_scripting_guide/c2171.html

function help()
{
echo 'Usage: server-protection.sh [flag]
Select modules to run the script.
-p, --passwd         Change the password
-sf,--sshfw          Change the SSH port and Firewall configuration
-f2, --file2         File2ban configuration
-h, --help           Help about the program'
}

function password()
{
echo 'Module: Change the password'
sleep 1
read -p "Do you wish to Change the password? (y/n): " your_answer
  case $your_answer in
    [Yy]* ) passwd
    ;;
    # break;;
    # error: ./server-protection.sh: line 13: break: only meaningful in a `for', `while', or `until' loop
    [Nn]* )
    ;;
  esac
sleep 1
}

function ssh()
{
echo "Module: Change the SSH port"
sleep 1
read -p "Do you wish to Change the SSH port? (y/n): " your_answer
  case $your_answer in
    [Yy]* ) read -p "Type your new SSH port: " ssh_port;
    echo 'export ssh_port='$ssh_port >> $HOME/.bash_profile
    . ~/.bash_profile
    sed -i.bak -e "s/^Port *=.*/Port = ${ssh_port}/" /etc/ssh/sshd_config
    sudo ufw allow ${ssh_port}/tcp
    sudo ufw deny 22
    ;;
    [Nn]* )
    ;;
  esac
sleep 1
}

function firewall()
{
echo 'Module: Firewall configuration'
sleep 1
read -p "Do you wish to do Firewall' configuration? (y/n): " your_answer
  if [[ "$your_answer" == [Yy]* ]]; 
  #  don't work "^[Yy]*" with "" and ^ because this is not a regular expression but a template expression
    then
    sudo apt update && sudo apt upgrde -y
    sudo apt install ufw -y
    sudo ufw allow ssh
    read -p "Type your node' API server Port ( by default 1317): " api_port
    read -p "Type your node' p2p connection Port ( by default 26656): " p2p_port
    read -p "Type your node' RPC Port ( by default 26657): " rpc_port
    read -p "Type your node' ABCI server Port ( by default 26658): " abci_port
    read -p "Type your node' Prometheus  Port ( by default 26660): " prometheus_port
    read -p "Type your node' pprof listen address Port ( by default 6060): " pprof_port
    read -p "Type your node' gRPC Port ( by default 9090): " gRPC_port
    read -p "Type your node' gRPC-web Port ( by default 9091): " gRPC_web_port
    sudo ufw allow $ssh_port/tcp
    # sudo ufw deny 22
    sudo ufw allow $api_port
    sudo ufw allow $p2p_port
    sudo ufw allow $rpc_port
    sudo ufw allow $abci_port
    sudo ufw allow $prometheus_port
    sudo ufw allow $pprof_port
    sudo ufw allow $gRPC
    sudo ufw allow $gRPC_web_port
    sudo ufw allow $ssh_port/tcp
    sudo ufw enable
    sudo ufw status
    sudo ufw status verbose
    ss -tulpn
  elif [[ "$your_answer" == [Nn]* ]]
    then
    echo "Go to the next module"
    echo "You could deny standart ssh port if you've changed it: sudo ufw deny 22"
  fi
  }

function fila2ban()
{
echo "Module: Install File2ban"
sleep 1
read -p "Do you wish to Install File2ban? (y/n): " your_answer
  case $your_answer in
    [Yy][Ee][Ss] ) 
    sudo apt install fail2ban
    sudo systemctl start fail2ban
    sudo systemctl enable fail2ban
    file2ban_conf=/etc/fail2ban/jail.conf
    sed -i.bak -e "s/^bantime *=.*/bantime = 5m/" ${file2ban_conf}
    sed -i.bak -e "s/^findtime *=.*/findtime = 5m/" ${file2ban_conf}
    sed -i.bak -e "s/^maxretry *=.*/maxretry = 5/" ${file2ban_conf}
    sed -i.bak -e "s/^logpath *=.*/logpath = "/var/log/sshd_log"/" ${file2ban_conf}
    sudo systemctl reload fail2ban
    sudo systemctl status fail2ban
    echo "You could check fail2ban' logs: journalctl -b -u fail2ban"
    ;;
    [Nn][Oo] ) echo "Go to the next module"
    ;;
  esac
sleep 1
}

if ! [ $# -ge 1 ] 
  then
  password
  ssh
  firewall
  fila2ban
else
  flags=$*
  for flag in $flags
  do
  case $flag in
  -p|--passwd)      password;;
  -sf|--sshfw)      ssh; firewall;;
  -f2|--file2)      fila2ban;;
  -h|--help)        help;;
  *)                echo 'If you dont know flags, please see: [--help]';;
  esac
  done
fi
exit
  





  





