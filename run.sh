#!/bin/sh

: ${CONFIG_FILE:=$USER_HOME/config.json}
: ${TLS_KEY_FILE:=./server.key}
: ${TLS_CERT_FILE:=./server.crt}

configure_user() {
  if [[ $(id ${SSH_USER} 2>/dev/null | grep -c ${SSH_USER})=="0" ]]; then
    echo "User '${SSH_USER}' doesn't exist. Creating it..."
    adduser -u ${SSH_USER_ID} -D -s /bin/sh -h ${USER_HOME} ${SSH_USER}
    chown -R ${SSH_USER}:${SSH_USER_GROUP} ${USER_HOME}
  fi
}

if [[ -z ${SSH_USER+x} ]]; then configure_user ; fi

if [ ! -r ${CONFIG_FILE} ]
then
  ### get address of ssh server
  #: ${SSH_HOST:=172.17.42.1}
  #: ${SSH_HOST:=172.17.0.1}
  #: ${SSH_USER:=core}
  ssh-keyscan -t rsa ${SSH_HOST} > ${USER_HOME}/.ssh/known_hosts
  #echo -e "{\n  \"shell\": \"ssh\",\n  \"shellArgs\": [ \"-i\", \"/home/core/.ssh/id_rsa\", \"${SSH_USER}@${SSH_HOST}\"]\n}" > ${CONFIG_FILE}
  #echo -e "{\n  \"shell\": \"ssh\",\n  \"shellArgs\": [\"${SSH_USER}@${SSH_HOST}\"]," > ${CONFIG_FILE}

  echo -e "{\n  \"shell\": \"ssh\",\n  \"shellArgs\": [\"-o\", \"StrictHostKeyChecking=no\", \"-i\", \"${USER_HOME}/.ssh/id_rsa\", \"${SSH_USER}@${SSH_HOST}\"]," > ${CONFIG_FILE}
  echo -e "\n  \"users\": {\n    \"admin\": \"${ADMIN_PASS}\"\n  }" >> ${CONFIG_FILE}
  [ -r ${TLS_KEY_FILE} ] && echo -e ",\n\"https\": {\n    \"key\": \"${TLS_KEY_FILE}\",\n    \"cert\": \"${TLS_KEY_FILE}\"\n  }" >> ${CONFIG_FILE}
  echo -e "\n}" >> ${CONFIG_FILE}
fi

#su - core -c "ssh -i \$HOME/.ssh/id_rsa core@172.17.0.1"
#su - core -c "/opt/node_modules/tty.js/bin/tty.js --config ${CONFIG_FILE}"
#sudo -u ${SSH_USER} /opt/node_modules/tty.js/bin/tty.js --config ${CONFIG_FILE}
#cat ${CONFIG_FILE}
/opt/node_modules/tty.js/bin/tty.js --config ${CONFIG_FILE}
