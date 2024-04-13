FROM ubuntu:22.04
ENV BROKEN=1
ENV FORCE_UNSAFE_CONFIGURE=1

## of https://github.com/freifunk-gluon/gluon/blob/master/contrib/docker/Dockerfile
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    file \
    git \
    python3 \
    python3-distutils \
    build-essential \
    gawk \
    unzip \
    libncurses5-dev \
    zlib1g-dev \
    libssl-dev \
    libelf-dev \
    wget \
    rsync \
    time \
    qemu-utils \
    ecdsautils \
    lua-check \
    shellcheck \
    libnss-unknown \
    openssh-client \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

## of https://gitlab.com/FreifunkChemnitz/gluon-build/-/blob/main/Dockerfile
RUN git clone --branch v2023.1.2 https://github.com/freifunk-gluon/gluon.git
WORKDIR /gluon
RUN git clone https://gitlab.com/FreifunkChemnitz/site-ffc.git site && \
    make update && \
    export DEFAULT_GLUON_RELEASE="b$(date '+%Y%m%d')" && \
    for target in $(make list-targets); do echo downloading ${target} && make GLUON_TARGET=${target} -j$(nproc||printf "2") download; done && \
    for target in $(make list-targets); do echo building ${target} && make GLUON_TARGET=${target} -j$(nproc||printf "2"); done
