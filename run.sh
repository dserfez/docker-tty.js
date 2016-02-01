#!/bin/sh

: ${CONFIG_FILE:=$HOME/config.json}

if [ ! -r ${CONFIG_FILE} ]
then
  : ${SSH_HOST:=172.17.42.1}
  : ${SSH_USER:=core}
  echo -e "{\n  \"shell\": \"ssh\",\n  \"shellArgs\": [\"${SSH_USER}@${SSH_HOST}\"]\n}" > ${CONFIG_FILE}
fi

/opt/node_modules/tty.js/bin/tty.js --config ${CONFIG_FILE}
