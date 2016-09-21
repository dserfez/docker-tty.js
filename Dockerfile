FROM alpine:3.4
MAINTAINER dserfez@gmail.com
RUN apk add --update nodejs python make g++ openssh-client sudo openssl && \
  mkdir -p /opt/ && cd /opt/ && \
  npm install tty.js && \
  apk del python make g++ gcc && \
  rm -Rf /tmp/* /var/lib/cache/apk/*

#ADD user.js /opt/node_modules/tty.js/node_modules/socket.io/node_modules/socket.io-client/node_modules/ws/node_modules/options/lib/user.js
ADD user.js /opt/node_modules/tty.js/static/
ADD run.sh /opt/run.sh

#WORKDIR /home/core

#USER core

#VOLUME /home/core/.ssh

EXPOSE 8080

CMD /opt/run.sh
