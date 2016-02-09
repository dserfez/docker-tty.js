#!/bin/bash

: ${USER_HOME:=/home/core}

KEY_FILE="${USER_HOME}/.ssh/id_rsa"

write_ak_file() {
  echo "'tty.js-host' entry not found in '.ssh/authorized_keys'. Adding it..."
  cat "${KEY_FILE}.pub" >> ${USER_HOME}/.ssh/authorized_keys && ADDED_TO_AH="true"
}

genkeys() {
  echo "Private key file '${KEY_FILE}' missing. Generating one..."
  ssh-keygen -N "" -f "${KEY_FILE}" -C "tty.js-host"
}

[ -r "${KEY_FILE}" ] || genkeys

[ $(grep tty.js-host ${USER_HOME}/.ssh/authorized_keys) ] || write_ak_file

#docker run -ti -p 8080:8080 -h tty --rm --name tty -v ${KEY_FILE}:/home/core/.ssh/id_rsa -e HOME=/home/core ttyjs #/bin/sh
#docker run --rm --name ttyjs -h ttyjs -v ${KEY_FILE}:/home/core/.ssh/id_rsa -e HOME=/home/core cycomf/ttyjs
docker run --rm --name ttyjs -h ttyjs \
  -v /home/core/.ssh:/home/core/.ssh \
  -u core \
  cycomf/ttyjs

[ ${ADDED_TO_AH} == "true" ] && sed -i 's|^.*tty.js-host$||' ${USER_HOME}/.ssh/authorized_keys
