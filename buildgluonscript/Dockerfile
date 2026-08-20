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

##################################################

FROM build-base

##################################################

RUN useradd -m -d /gluon -u 100 -g 100 -o gluon
USER gluon
WORKDIR /workspace
COPY --chmod=755 buildgluonscript.sh .
VOLUME /workspace/output
ENV GLUON_OUTPUTDIR=/workspace/output

ENTRYPOINT ["/workspace/buildgluonscript.sh"]
