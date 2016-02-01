# README for docker-ttyjs

## About

A small container which serves the famous web browser shell [tty.js](https://github.com/chjj/tty.js/)

## Configuration

By default starting a terminal will start 
* Host: 172.17.42.1
* User: core
* config file: ~/config.json

### Environment variables
* SSH_HOST
* SSH_USER
* CONFIG_FILE

### Config file

Mounted in ~/home/core/config.json

**Default:**

```json
{
  "shell": "ssh"
  "shellArgs": ["core@172.17.42.1"]
}

```

## Run


### CoreOS