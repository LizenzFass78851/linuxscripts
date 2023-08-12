FROM ubuntu:22.04
ENV BROKEN=1
ENV FORCE_UNSAFE_CONFIGURE=1

RUN sudo apt update && sudo apt install -y ecdsautils build-essential curl gawk git libncurses-dev lua-check python3 shellcheck time unzip wget rsync subversion qemu-utils zlib1g-dev libssl-dev libelf-dev file && \
    rm -rf /var/lib/apt/lists/* && \
    git clone --branch v2023.1 https://github.com/freifunk-gluon/gluon.git
WORKDIR /gluon
RUN git clone https://gitlab.com/FreifunkChemnitz/site-ffc.git site && \
    make update && \
    for target in $(make list-targets); do echo downloading ${target} && make GLUON_TARGET=${target} -j$(nproc||printf "2") download; done && \
    for target in $(make list-targets); do echo building ${target} && make GLUON_TARGET=${target} -j$(nproc||printf "2"); done
