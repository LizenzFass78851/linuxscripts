FROM debian:trixie-slim AS build-base
ENV BROKEN=1
ENV FORCE_UNSAFE_CONFIGURE=1

##################################################

## of https://github.com/freifunk-gluon/gluon/blob/master/contrib/docker/Dockerfile
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    clang \
    ecdsautils \
    file \
    gawk \
    git \
    libelf-dev \
    libncurses5-dev \
    libnss-unknown \
    libssl-dev \
    llvm \
    lua-check \
    openssh-client \
    python3 \
    python3-dev \
    python3-pyelftools \
    python3-setuptools \
    qemu-utils \
    rsync \
    shellcheck \
    swig \
    time \
    unzip \
    wget \
    zlib1g-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -m -d /gluon -u 100 -g 100 -o gluon
USER gluon
VOLUME /gluon
WORKDIR /gluon

##################################################

FROM build-base

##################################################

ARG SCRIPT_GLUON_REPO="https://github.com/freifunk-gluon/gluon.git"
ARG SCRIPT_GLUON_BRANCH="v2025.1.x"

ARG SCRIPT_GLUON_SITE_REPO="https://github.com/FreifunkVogtland/site-ffv.git"
#ARG SCRIPT_GLUON_SITE_REPO="https://gitlab.com/FreifunkChemnitz/site-ffc.git"

##################################################

## of https://gitlab.com/FreifunkChemnitz/gluon-build/-/blob/main/Dockerfile
RUN git clone --branch $SCRIPT_GLUON_BRANCH $SCRIPT_GLUON_REPO .
RUN git clone $SCRIPT_GLUON_SITE_REPO site && \
    make update && \
    export DEFAULT_GLUON_RELEASE="b$(date '+%Y%m%d')" && \
    for target in $(make list-targets); do echo downloading ${target} && make GLUON_TARGET=${target} -j$(nproc||printf "2") download; done && \
    for target in $(make list-targets); do echo building ${target} && make GLUON_TARGET=${target} -j$(nproc||printf "2"); done
