#!/bin/bash
# insecure.sh
#   Used to start the cycomf/tty.js container.
#   Listening on port 9876/tcp of the Docker host.
#   WITHOUT AUTHENTICATION.
#   Meant for running in VMs on host-only interfaces.
#   More information here: https://github.com/dserfez/docker-tty.js
# author: dserfez@gmail.com
# license:


### BEGIN CONFIG SECTION

#DOCKER_OPTS="-ti"
DOCKER_OPTS="-i "
#DOCKER_OPTS="-di"

SSH_USER=$(id -nu)
USER_HOME=$HOME

#: ${ADMIN_PASS:=admin}
#: ${SSH_HOST:=172.17.42.1}
#: ${SSH_USER:=core}

#: ${USER_HOME:=/home/${SSH_USER}}
: ${DOCKER_IFACE:=docker0}

### end CONFIG SECTION

KEY_FILE="${USER_HOME}/.ssh/id_rsa"

set_ssh_host() {
  export SSH_HOST=$(ip -o -f inet address show dev ${DOCKER_IFACE} | awk '{print $4}' | cut -d"/" -f1)
}

user_details() {
  export SSH_USER_ID=$(id -u ${SSH_USER})
  export SSH_USER_GROUP=$(id -gn ${SSH_USER})
  export SSH_USER_GID=$(id -g ${SSH_USER})
}

write_ak_file() {
  echo "'tty.js-host' entry not found in '.ssh/authorized_keys'. Adding it..."
  cat "${KEY_FILE}.pub" >> ${USER_HOME}/.ssh/authorized_keys && ADDED_TO_AH="true"
}

genkeys() {
  echo "Private key file '${KEY_FILE}' missing. Generating one..."
  ssh-keygen -N "" -f "${KEY_FILE}" -C "tty.js-host"
}

user_details

#if [[ -z ${SSH_HOST+x} ]]; then set_ssh_host ; fi
if [[ -z ${SSH_HOST} ]]; then set_ssh_host ; fi

[ -r "${KEY_FILE}" ] || genkeys

[ $(grep tty.js-host ${USER_HOME}/.ssh/authorized_keys) ] || write_ak_file

#docker run -ti -p 8080:8080 -h tty --rm --name tty -v ${KEY_FILE}:/home/core/.ssh/id_rsa -e HOME=/home/core ttyjs #/bin/sh
#docker run --rm --name ttyjs -h ttyjs -v ${KEY_FILE}:/home/core/.ssh/id_rsa -e HOME=/home/core cycomf/ttyjs

[ -z ${ONLINE} ] || docker pull cycomf/ttyjs

docker inspect -f "{{.State.Status}}" ttyjs 2>/dev/null
[ $? == 0 ] && docker rm -f ttyjs

docker run $DOCKER_OPTS --name ttyjs -h $(hostname -f) \
  -p 9876:8080 \
  -v ${USER_HOME}/.ssh:${USER_HOME}/.ssh \
  -e SSH_HOST=${SSH_HOST} \
  -e SSH_USER=${SSH_USER} \
  -e SSH_USER_ID=${SSH_USER_ID} \
  -e USER_HOME=${USER_HOME} \
  -e SSH_USER_GROUP=${SSH_USER_GROUP} \
  -e SSH_USER_GID=${SSH_USER_GID} \
  -e SSH_USER=${SSH_USER} \
  -e ADMIN_PASS=${ADMIN_PASS} \
  -e INSECURE=true \
  cycomf/ttyjs

[ ${ADDED_TO_AH} == "true" ] && sed -i 's|^.*tty.js-host$||' ${USER_HOME}/.ssh/authorized_keys
