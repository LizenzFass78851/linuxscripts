## Build Gluon Script
- the script carries out the workflow to build gluon with the ffc site config
- All targets with all cpu cores are used when building and broken equals 1


#### the following packages are required for `ubuntu:22.04` and `debian:bookworm`
Simply enter the command below and all the necessary packages will be installed under ubuntu and debian
````bash
apt update && apt install -y --no-install-recommends \
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
    python3-distutils \
    python3-pyelftools \
    python3-setuptools \
    qemu-utils \
    rsync \
    shellcheck \
    swig \
    time \
    unzip \
    wget \
    zlib1g-dev
````
