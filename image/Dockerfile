FROM alpine:3.21

ENV _BASH_VERSION 4.1.1
ENV _BASH_BASELINE 4.1
ENV _BASH_LATEST_PATCH 1

RUN apk add --no-cache --virtual .build-deps \
  bison \
  coreutils \
  dpkg-dev dpkg \
  gcc \
  libc-dev \
  make \
  ncurses-dev \
  patch \
  tar 

RUN apk add --no-cache openrc

COPY alpine3.21.patch /usr/local/src/tianon-bash-patches/
COPY build-bash.sh /usr/local/src/build-bash.sh

RUN chmod +x /usr/local/src/build-bash.sh && /usr/local/src/build-bash.sh

RUN apk add --no-cache openrc apache2 openssh
RUN echo "root:root" | chpasswd

RUN ln -s /usr/local/bin/bash /bin/bash

COPY files/sshd/sshd_config /etc/ssh/sshd_config
COPY files/apache2/submit-comment.cgi /var/www/localhost/cgi-bin/submit-comment.cgi
COPY files/apache2/httpd.conf /etc/apache2/httpd.conf

COPY docker-entrypoint.sh /usr/local/bin/
COPY files/misc/motd /etc/motd
ENTRYPOINT ["docker-entrypoint.sh"]

