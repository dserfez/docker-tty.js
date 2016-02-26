#!/bin/bash

### BEGIN CONFIG CESTION

DOCKER_OPTS="-ti"

: ${SSH_HOST:=172.17.42.1}
: ${SSH_USER:=core}

: ${USER_HOME:=/home/core}

### end CONFIG CESTION

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
docker run $DOCKER_OPTS --rm --name ttyjs -h ttyjs \
  -v /home/core/.ssh:/home/core/.ssh \
  -e SSH_HOST=${SSH_HOST} \
  -e SSH_USER=${SSH_USER} \
  -u core \
  cycomf/ttyjs

[ ${ADDED_TO_AH} == "true" ] && sed -i 's|^.*tty.js-host$||' ${USER_HOME}/.ssh/authorized_keys

