FROM ubuntu:latest

ENV GID=1001 \
    UID=1001 \
    SECRET=0423bab3aea2d87d5eedd9a4e8173618 \
    CONTACT=contact@domain.ext \
    REPORT=contact@domain.ext \
    MAX_FILE_SIZE=2147483648 \
    WEBROOT=/ \
    DEFAULT_DELAY=1 \
    MAX_DELAY=0 \
    THEME=default \
    ALLOW_PWD_ON_FILES=1 \
    POLICY_WHEN_FULL=warn

LABEL description="lufi based Ubuntu" \
      tags="latest 0.04.2" \
      maintainer="xataz <https://github.com/xataz>" \
      build_ver="201909271541"

RUN apt-get update && apt-get install -y locales \
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

RUN apt-get update && apt-get upgrade -y \
    && apt-get install -y \
                vim \
                git \
                cpanminus \
                build-essential \
                libssl-dev \
                libio-socket-ssl-perl \
                liblwp-protocol-https-perl
    
RUN cpan Carton
RUN apt-get install -y \
                libpq-dev \
                libmariadbd-dev \
    && rm -rf /var/lib/apt-get/lists/*

RUN git clone https://framagit.org/fiat-tux/hat-softwares/lufi.git /usr/lufi \
    && cd /usr/lufi \
    && carton install --deployment  --without=test --without=sqlite --without=postgresql \
    && cpanm Mojo::SQLite


VOLUME /usr/lufi/data /usr/lufi/files

EXPOSE 8081

COPY startup /usr/local/bin/startup
COPY lufi.conf /usr/lufi/lufi.conf
RUN chmod +x /usr/local/bin/startup

CMD ["/usr/local/bin/startup"]
