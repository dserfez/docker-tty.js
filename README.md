# README for docker-ttyjs

## About

A small container (<70MB) which serves the famous web browser shell [tty.js](https://github.com/chjj/tty.js/)

After opening in web browser it automatically starts a new tty terminal (configured in _user.js_) in the web browser, which initiates the connection to the configured _$SSH_HOST_, as _$SSH_USER_, using privkey authentication identity from _~/.ssh/id_rsa_.

!!!KEEP IT BEHIND TLS!!!

The connection (typed usernames, passwords and commands) from the browser to tty.js server container is in plaintext.

[web browser]----->[ttyjs container]----->[ssh server]

## Configuration

By default starting a terminal will start
* Host: 172.17.0.1
* User: core
* config file: ~/config.json

### Environment variables
* `SSH_HOST` (defaults to IP of interface _docker0_ or by envirnomnet variable `DOCKER_IFACE` )
* `SSH_USER`
* `CONFIG_FILE`

### Config file

Created in /home/core/config.json

**Default:**

```json
{
  "shell": "ssh",
  "shellArgs": ["core@172.17.0.1"],
  "https": {
    "key": "./server.key",
    "cert": "./server.crt"
  }
}

```

## Run

```
docker run --rm --name ttyjs -h ttyjs \
  -v /home/core/.ssh:/home/core/.ssh \
  -u core \
  cycomf/ttyjs
```
