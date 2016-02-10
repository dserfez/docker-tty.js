#!/bin/sh

: ${CONFIG_FILE:=$HOME/config.json}
: ${TLS_KEY_FILE:=./server.key}
: ${TLS_CERT_FILE:=./server.crt}

if [ ! -r ${CONFIG_FILE} ]
then
#  : ${SSH_HOST:=172.17.42.1}
  : ${SSH_HOST:=172.17.0.1}
  : ${SSH_USER:=core}
  ssh-keyscan -t rsa ${SSH_HOST} > .ssh/known_hosts
  #echo -e "{\n  \"shell\": \"ssh\",\n  \"shellArgs\": [ \"-i\", \"/home/core/.ssh/id_rsa\", \"${SSH_USER}@${SSH_HOST}\"]\n}" > ${CONFIG_FILE}
  echo -e "{\n  \"shell\": \"ssh\",\n  \"shellArgs\": [\"${SSH_USER}@${SSH_HOST}\"]" > ${CONFIG_FILE}
  echo -e "\n  \"users\": {\n    \"admin\": \"admin\"\n  }," >> ${CONFIG_FILE}
  [ -r ${TLS_KEY_FILE} ] && echo -e ",\n\"https\": {\n    \"key\": \"${TLS_KEY_FILE}\",\n    \"cert\": \"${TLS_KEY_FILE}\"\n  }" >> ${CONFIG_FILE}
  echo -e "\n}" >> ${CONFIG_FILE}
fi

#su - core -c "ssh -i \$HOME/.ssh/id_rsa core@172.17.0.1"
#su - core -c "/opt/node_modules/tty.js/bin/tty.js --config ${CONFIG_FILE}"
/opt/node_modules/tty.js/bin/tty.js --config ${CONFIG_FILE}
