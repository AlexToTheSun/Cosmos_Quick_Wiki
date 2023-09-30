#!/usr/bin/env bash
if [ ! $DIRECTORY ];
  # if test ! $DIRECTORY ;
  # if [ -z $DIRECTORY ]
  # proverka peremennoy: https://g-soft.info/articles/7293/bash-proverit-pusta-li-peremennaya/
  # proverka usliviy: https://www.opennet.ru/docs/RUS/bash_scripting_guide/c2171.html
  then
        read -p "Enter name of your node' directory : " DIRECTORY
        # about read: https://tokmakov.msk.ru/blog/item/68
        echo 'export DIRECTORY='$DIRECTORY >> $HOME/.bash_profile
        . ~/.bash_profile

  #  elif [ ! $AGORIC_NODENAME ];
fi

source ~/.bash_profile
echo 'Directory of your node: ' $HOME/.$DIRECTORY

sed -i.bak -e "s/^indexer *=.*/indexer = \""null"\"/" $HOME/.$DIRECTORY/config/config.toml && \
rm $HOME/.$DIRECTORY/data/tx_index.db/*
echo DONE
