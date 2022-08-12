FROM ubuntu:22.04

# Get add-apt-repository
RUN apt update
RUN apt install -y software-properties-common

# Add PPA for Racket
RUN add-apt-repository ppa:plt/racket

## Install dependencies
# apt dependencies
RUN apt install -y \
  autoconf \
  bison \
  ccache \
  cmake \
  curl \
  flex \
  g++ \
  git \
  git \
  libfl-dev \
  libfl2 \
  libgoogle-perftools-dev \
  libssl-dev \
  libzmq3-dev \
  llvm-14 \
  make \
  numactl \
  openssl \
  perl \
  perl-doc \
  python3 \
  python3-pip \
  racket \
  wget \
  zlib1g \
  zlib1g-dev

# Point to llvm-config binary. Alternatively, make sure you have a binary called
# `llvm-config` on your PATH.
ENV LLVM_CONFIG=llvm-config-14

# Make a binary for `lit`. If you're on Mac, you can install lit via Brew.
# Ubuntu doesn't have a binary for it, but it is available on pip and is
# installed later in this Dockerfile.
WORKDIR /root
RUN mkdir -p /root/.local/bin \
  && echo "#!/usr/bin/env python3" >> /root/.local/bin/lit \
  && echo "from lit.main import main" >> /root/.local/bin/lit \
  && echo "if __name__ == '__main__': main()" >> /root/.local/bin/lit \
  && chmod +x /root/.local/bin/lit
ENV PATH="/root/.local/bin:${PATH}"

# Build and install latest boolector.
WORKDIR /root
ARG MAKE_JOBS=2
RUN git clone https://github.com/boolector/boolector \
  && cd boolector \
  && git checkout 3.2.2 \
  && ./contrib/setup-lingeling.sh \
  && ./contrib/setup-btor2tools.sh \
  && ./configure.sh \
  && cd build \
  && make -j${MAKE_JOBS} install

# Install Yosys and other OSS hardware tools from prebuilt binaries.
#
# If we get an error here, we likely just need to add other branches for other
# architectures.
WORKDIR /root
RUN if [ "$(uname -m)" = "x86_64" ] ; then \
  wget https://github.com/YosysHQ/oss-cad-suite-build/releases/download/2022-03-23/oss-cad-suite-linux-x64-20220323.tgz -q -O oss-cad-suite.tgz; \
  else \
  exit 1; \
  fi \
  && tar xf oss-cad-suite.tgz
ENV PATH="/root/oss-cad-suite/bin:${PATH}"

# Build and install latest Verilator.
ARG MAKE_JOBS=2
RUN  git clone https://github.com/verilator/verilator \
  && unset VERILATOR_ROOT \
  && cd verilator \
  && git checkout v4.222 \
  && autoconf \
  && ./configure \
  && make -j${MAKE_JOBS} \
  && make install

# pip dependencies
WORKDIR /root/lakeroad
ADD requirements.txt requirements.txt
RUN pip install -r requirements.txt

# raco (Racket) dependencies
# First, fix https://github.com/racket/racket/issues/2691
RUN raco setup --doc-index --force-user-docs
RUN raco pkg install --deps search-auto --batch \
  fmt \
  rosette

# Install Rust
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y
ENV PATH="/root/.cargo/bin:$PATH"

ENV LAKEROAD_DIR=/root/lakeroad

# Build Rust package.
WORKDIR /root/lakeroad
ADD ./rust ./rust
RUN cargo build --manifest-path /root/lakeroad/rust/Cargo.toml

# Add other Lakeroad files. It's useful to put this as far down as possible. In
# general, only ADD files just before they're needed. This maximizes the ability
# to cache intermediate containers and minimizes rebuilding.
WORKDIR /root/lakeroad
ADD ./f4pga-arch-defs ./fmt.sh ./Nitro-Parts-lib-Xilinx ./python ./racket ./run-tests.sh ./skywater-pdk-libs-sky130_fd_sc_hd ./SOFA ./utils ./

WORKDIR /root/lakeroad
CMD [ "/bin/bash", "run-tests.sh" ]
