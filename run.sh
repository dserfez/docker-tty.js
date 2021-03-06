#!/bin/sh

: ${CONFIG_FILE:=$USER_HOME/config.json}
: ${TLS_KEY_FILE:=$USER_HOME/ttyjs.key}
: ${TLS_CERT_FILE:=$USER_HOME/ttyjs.crt}
: ${TTYJS_PORT:=9876}

configure_user() {
  if [[ $(id ${SSH_USER} 2>/dev/null | grep -c ${SSH_USER})=="0" ]]; then
    echo "User '${SSH_USER}' doesn't exist. Creating it..."
    adduser -u ${SSH_USER_ID} -D -s /bin/sh -h ${USER_HOME} ${SSH_USER}
    chown -R ${SSH_USER}:${SSH_USER_GROUP} ${USER_HOME}
  fi
}

generate_keyfiles() {
  SUBJ_CN=$(hostname)
  SUBJ_O=$(dnsdomainname || echo Private)
  SUBJ_C=$(echo $LANG | cut -d"_" -f2 | cut -d "." -f1)
  SUBJ="/C=${SUBJ_C}/O=${SUBJ_O}/CN=${SUBJ_CN}"
echo $SUBJ
  openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout ${TLS_KEY_FILE} -out ${TLS_CERT_FILE} -subj ${SUBJ}
}

if [[ -z ${SSH_USER} ]]; then configure_user ; fi

if [ ! -r ${CONFIG_FILE} ]
then
  echo "Config file ${CONFIG_FILE} missing. Generating it..."
  ### get address of ssh server
  #: ${SSH_HOST:=172.17.42.1}
  #: ${SSH_HOST:=172.17.0.1}
  #: ${SSH_USER:=core}
  ssh-keyscan -t rsa ${SSH_HOST} > ${USER_HOME}/.ssh/known_hosts
  #echo -e "{\n  \"shell\": \"ssh\",\n  \"shellArgs\": [ \"-i\", \"/home/core/.ssh/id_rsa\", \"${SSH_USER}@${SSH_HOST}\"]\n}" > ${CONFIG_FILE}
  #echo -e "{\n  \"shell\": \"ssh\",\n  \"shellArgs\": [\"${SSH_USER}@${SSH_HOST}\"]," > ${CONFIG_FILE}

  echo -e "{\n  \"shell\": \"ssh\",\n  \"shellArgs\": [\"-o\", \"StrictHostKeyChecking=no\", \"-i\", \"${USER_HOME}/.ssh/id_rsa\", \"${SSH_USER}@${SSH_HOST}\"]," > ${CONFIG_FILE}
  echo -e "\n  \"users\": {\n    \"admin\": \"${ADMIN_PASS}\"\n  }" >> ${CONFIG_FILE}
  echo -e ",\n\"https\": {\n    \"key\": \"${TLS_KEY_FILE}\",\n    \"cert\": \"${TLS_CERT_FILE}\"\n  }," >> ${CONFIG_FILE}
  echo -e "  \"port\": ${TTYJS_PORT}" >> ${CONFIG_FILE}
  echo -e "\n}" >> ${CONFIG_FILE}
fi

[[ -r ${TLS_KEY_FILE} ]] || generate_keyfiles
[[ -r ${TLS_CERT_FILE} ]] || generate_keyfiles

#su - core -c "ssh -i \$HOME/.ssh/id_rsa core@172.17.0.1"
#su - core -c "/opt/node_modules/tty.js/bin/tty.js --config ${CONFIG_FILE}"
#sudo -u ${SSH_USER} /opt/node_modules/tty.js/bin/tty.js --config ${CONFIG_FILE}
#cat ${CONFIG_FILE}

echo "The ttyjs container is not listening on any external ports by default."
echo "In order to make it accessible, you can do: "
echo "sudo iptables -t nat -A PREROUTING -p tcp --dport 8080 -j DNAT --to $(ip -o -f inet a | grep eth0 | awk '{print $4}' | cut -d"/" -f1)"
echo -e "\n\n\nMY IP IS: $(ip -o -f inet a s dev eth0 | awk '{print $4}' | cut -d"/" -f1)"
/opt/node_modules/tty.js/bin/tty.js --config ${CONFIG_FILE}
