# README for docker-ttyjs

## About

A small container (<70MB) which serves the famous web browser shell [tty.js](https://github.com/chjj/tty.js/)

After opening in web browser it automatically starts a new tty terminal (configured in _user.js_) in the web browser, which initiates the connection to the configured _$SSH_HOST_, as _$SSH_USER_, using provkey authentication identity from _~/.ssh/id_rsa_.

!!!KEEP IT BEHIND TLS!!!

The connection (typed usernames, passwords and commands) from the browser to tty.js server container is in plaintext.

[web browser]----->[ttyjs container]----->[ssh server]

## Configuration

By default starting a terminal will start 
* Host: 172.17.0.1
* User: core
* config file: ~/config.json

### Environment variables
* SSH_HOST
* SSH_USER
* <del>CONFIG_FILE</del>

### Config file

Created in /home/core/config.json

**Default:**

```json
{
  "shell": "ssh",
  "shellArgs": ["core@172.17.0.1"]
}

```

## Run

```
docker run --rm --name ttyjs -h ttyjs \
  -v ${KEY_FILE}:/home/core/.ssh/id_rsa \
  -e HOME=/home/core \
  cycomf/ttyjs
```
