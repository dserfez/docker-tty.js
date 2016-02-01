#!/bin/bash

KEY_FILE="${HOME}/.ssh/id_rsa"

write_ak_file() {
  echo "'tty.js-host' entry not found in '.ssh/authorized_keys'. Saving it..."
  cat "${KEY_FILE}.pub" >> .ssh/authorized_keys
}

genkeys() {
  echo "Private key file '${KEY_FILE}' missing. Generating one..."
  ssh-keygen -N "" -f "${KEY_FILE}" -C "tty.js-host"
  [ $(grep tty.js-host .ssh/authorized_keys) ] || write_ak_file
}

[ -r "${KEY_FILE}" ] || genkeys

#docker run -ti -p 8080:8080 -h tty --rm --name tty -v ${KEY_FILE}:/home/core/.ssh/id_rsa -e HOME=/home/core ttyjs #/bin/sh
docker run --rm --name ttyjs -h ttyjs -v ${KEY_FILE}:/home/core/.ssh/id_rsa -e HOME=/home/core cycomf/ttyjs
