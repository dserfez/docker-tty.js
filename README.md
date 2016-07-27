# README for docker-ttyjs

## About

A small container (<70MB) which serves the famous web browser shell [tty.js](https://github.com/chjj/tty.js/)

After opening in web browser it automatically starts a new tty terminal (configured in _user.js_) in the web browser, which initiates the connection to the configured _$SSH_HOST_, as _$SSH_USER_, using privkey authentication identity from _~/.ssh/id_rsa_.

!!!KEEP IT BEHIND TLS!!!

The connection (typed usernames, passwords and commands) from the browser to tty.js server container is in plaintext.

[web browser]----->[ttyjs container]----->[ssh server]

## Configuration

By default starting a terminal will start
* Host: IPv4 of docker0 interface 
* User: username of the user staring the start_script.sh
* config file: ~/config.json

### Environment variables
* `SSH_HOST` - address of the ssh server (defaults to IP of interface _docker0_ or by envirnomnet variable `DOCKER_IFACE` )
* `SSH_USER` - user which will connect to the ssh server 
* `CONFIG_FILE` - tty.js config file (https://github.com/chjj/tty.js/#configuration)
* `DOCKER_IFACE`

### Config file

Created in /home/core/config.json

More info: https://github.com/chjj/tty.js/#configuration

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

curl -L https://git.io/vKbYH | sh

```
docker run --rm --name ttyjs -h ttyjs \
  -v /home/core/.ssh:/home/core/.ssh \
  -u core \
  cycomf/ttyjs
```

## Behind reverse proxy
Simplest INSECURE nginx reverse proxy configuration with URI `/shell/` to access ttyjs:

```
daemon off;

http {
  server {
  listen 80;
    location /shell/ {
        proxy_pass http://TTYJS_CONTAINER_IP:8080/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_read_timeout 43200000;

        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host $http_host;
        proxy_set_header X-NginX-Proxy true;
    }
  }
}

events {  }

```

To run the reverse proxy with official nginx Docker image:

```
docker run -ti --rm --name nginx -p 80:80 -v /path/to/above/config/file.conf:/etc/nginx/nginx.conf:ro nginx nginx -c /etc/nginx/nginx.conf
```
