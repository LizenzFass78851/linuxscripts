FROM ubuntu
ENV BROKEN=1
ENV FORCE_UNSAFE_CONFIGURE=1

RUN apt update && \
    apt install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    curl \
    gawk \
    file \
    git \
    libncurses-dev \
    lua-check \
    python2 \
    shellcheck \
    time \
    unzip \
    wget \
    qemu-utils \
    && rm -rf /var/lib/apt/lists/* && \
    git clone --branch v2021.1.2 https://github.com/freifunk-gluon/gluon.git
WORKDIR /gluon
RUN git clone https://gitlab.com/FreifunkChemnitz/site-ffc.git site && \
    make update && \
    for target in $(make list-targets); do echo downloading ${target} && make GLUON_TARGET=${target} -j$(nproc||printf "2") download; done && \
    for target in $(make list-targets); do echo building ${target} && make GLUON_TARGET=${target} -j$(nproc||printf "2"); done
