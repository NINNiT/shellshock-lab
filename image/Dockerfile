FROM alpine:3.21 as base_dependencies

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

FROM base_dependencies as build

ENV _BASH_VERSION 4.1.1
ENV _BASH_BASELINE 4.1
ENV _BASH_LATEST_PATCH 1

COPY alpine3.21.patch /usr/local/src/tianon-bash-patches/
COPY build-bash.sh /usr/local/src/build-bash.sh

RUN chmod +x /usr/local/src/build-bash.sh && /usr/local/src/build-bash.sh

COPY docker-entrypoint.sh /usr/local/bin/
COPY motd /etc/motd
ENTRYPOINT ["docker-entrypoint.sh"]


