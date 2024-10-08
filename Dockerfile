# syntax=docker/dockerfile-upstream:master-labs
# The above enables use of ADD of git repo.

FROM ubuntu:22.04
ARG MAKE_JOBS=2
SHELL ["/bin/bash", "-c"] 

# Update, get add-apt-repository, add PPA for Racket, update again.
RUN apt update \
  &&  apt install -y software-properties-common \
  &&  add-apt-repository ppa:plt/racket \
  && apt update

# Install apt dependencies
# `noninteractive` prevents the tzdata package from asking for a timezone on the
# command line.
ENV DEBIAN_FRONTEND=noninteractive
RUN apt install -y \
  autoconf \
  bison \
  ccache \
  cmake \
  curl \
  flex \
  g++ \
  git \
  libboost-filesystem-dev \
  libfl-dev \
  libfl2 \
  libgmp-dev \
  libgoogle-perftools-dev \
  libreadline-dev \
  libssl-dev \
  libzmq3-dev \
  llvm-14 \
  make \
  ninja-build \
  numactl \
  openssl \
  perl \
  perl-doc \
  pkg-config \
  python3 \
  python3-pip \
  racket \
  tcl \
  tcl8.6-dev \
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

# Install a bunch of useful tools from prebuilt binaries. Thanks to YosysHQ for
# making this available!
#
# If we get an error here, we likely just need to add other branches for other
# architectures.
#
# TODO(@gussmith23): Could shrink Docker image by deleting a bunch of uneeded
# binaries, or only taking the binaries we need. However, I found that moving
# stuff out of oss-cad-suite causes things to break.
#
# WIP: I'm working on removing dependence on oss-cad-suite.
#
# WORKDIR /root
# RUN source /root/dependencies.sh \
#   && if [ "$(uname -m)" = "x86_64" ] ; then \
#   wget https://github.com/YosysHQ/oss-cad-suite-build/releases/download/$OSS_CAD_SUITE_DATE/oss-cad-suite-linux-x64-$(echo $OSS_CAD_SUITE_DATE | tr -d "-").tgz -q -O oss-cad-suite.tgz; \
#   else \
#   exit 1; \
#   fi \
#   && tar xf oss-cad-suite.tgz \
#   && rm oss-cad-suite.tgz \
#   # Delete binaries we don't need (and that we explicitly build other versions
#   # of).
#   && rm oss-cad-suite/bin/yosys \
#   && rm oss-cad-suite/bin/bitwuzla
# # Make sure that .local/bin has precedence over oss-cad-suite/bin. I realize
# # we add ./local/bin to the PATH twice, but I just want to document that we want
# # things in .local/bin to take precedence, and duplicate PATH entries won't
# # break anything.
# ENV PATH="/root/.local/bin:/root/oss-cad-suite/bin:${PATH}"

# pip dependencies
WORKDIR /root/lakeroad
ADD requirements.txt requirements.txt
RUN pip install -r requirements.txt

# This file tracks the commit hashes of the various dependencies we use.
ADD dependencies.sh /root/dependencies.sh

# Build Bitwuzla.
WORKDIR /root
RUN source /root/dependencies.sh \
  && mkdir bitwuzla \
  && wget -qO- https://github.com/bitwuzla/bitwuzla/archive/$BITWUZLA_COMMIT_HASH.tar.gz | tar xz -C bitwuzla --strip-components=1 \
  && cd bitwuzla \
  && ./configure.py --prefix=/root/.local \
  && cd build \
  && ninja -j${MAKE_JOBS} \
  && ninja install \
  && rm -rf /root/bitwuzla

# Install raco (Racket) dependencies. 
WORKDIR /root
RUN \
  # First, fix https://github.com/racket/racket/issues/2691 by building the
  # docs.
  raco setup --doc-index --force-user-docs \
  # Install packages.
  && raco pkg install --deps search-auto --batch \
  rosette \
  yaml \
  # Install fmt directly from GitHub. This prevents the version from changing on
  # us unexpectedly.
  && cd /root \
  && git clone https://github.com/sorawee/fmt \
  && cd fmt \
  && source /root/dependencies.sh \
  && git checkout $RACKET_FMT_COMMIT_HASH \
  && raco pkg install --deps search-auto --batch

ENV LAKEROAD_DIR=/root/lakeroad
ENV PYTHONPATH="${LAKEROAD_DIR}/python:${PYTHONPATH}"

# Build STP.
WORKDIR /root
RUN apt-get install -y git cmake bison flex libboost-all-dev python2 perl && \
  source /root/dependencies.sh && \
  mkdir stp && cd stp && \
  wget -qO- https://github.com/$STP_USER_AND_REPO/archive/$STP_COMMIT_HASH.tar.gz | tar xz --strip-components=1 && \
  ./scripts/deps/setup-gtest.sh && \
  ./scripts/deps/setup-outputcheck.sh && \
  ./scripts/deps/setup-cms.sh && \
  ./scripts/deps/setup-minisat.sh && \
  mkdir build && \
  cd build && \
  cmake .. -DCMAKE_INSTALL_PREFIX=/root/.local && \
  make -j ${MAKE_JOBS}
# TODO(@gussmith23): Install and delete folder once
# https://github.com/stp/stp/issues/479 is fixed.
# make install && \
# rm -rf /root/stp
# And after that we also don't need to add STP to the path.
ENV PATH="/root/stp/build:${PATH}"
# TODO(@gussmith23): We shouldn't need this once https://github.com/stp/stp/issues/481 is fixed or https://github.com/stp/stp/pull/482 works correctly.
ENV LD_LIBRARY_PATH="/root/stp/deps/cadical/build:/root/stp/deps/cadiback/:$LD_LIBRARY_PATH"

# Build Yosys.
WORKDIR /root 
RUN cd /root \
# TODO(@cknizek?): Replace this with archive download
# Yosys depends on a submodule (abc) and so downloading an archive doesn't work.
# Once this issue (https://github.com/dear-github/dear-github/issues/214)...
# ... is resolved, we can go back to downloading an archive.
&& git clone https://github.com/YosysHQ/yosys.git \
&& cd yosys \
&& source /root/dependencies.sh \
&& git checkout $YOSYS_COMMIT_HASH \
&& git submodule update --init --recursive \
&& PREFIX="/root/.local" CPLUS_INCLUDE_PATH="/usr/include/tcl8.6/:$CPLUS_INCLUDE_PATH" make config-gcc \
&& PREFIX="/root/.local" CPLUS_INCLUDE_PATH="/usr/include/tcl8.6/:$CPLUS_INCLUDE_PATH" make -j ${MAKE_JOBS} install \
&& rm -rf /root/yosys

# Build CVC5.
RUN source /root/dependencies.sh \
  && mkdir cvc5 && cd cvc5 \
  && wget -qO- https://github.com/cvc5/cvc5/archive/$CVC5_COMMIT_HASH.tar.gz  | tar xz --strip-components=1 \
  && ./configure.sh --prefix="/root/.local"  --auto-download \
  && cd ./build \
  && make -j ${MAKE_JOBS} \
  && make -j ${MAKE_JOBS} install \
  && rm -rf /root/cvc5

# Build Yices2.
RUN source /root/dependencies.sh \
  && apt-get install -y gperf \
  && mkdir yices2 && cd yices2 \
  && wget -qO- https://github.com/SRI-CSL/yices2/archive/$YICES2_COMMIT_HASH.tar.gz | tar xz --strip-components=1 \
  && autoconf \
  && ./configure --prefix="/root/.local" \
  && make -j ${MAKE_JOBS} \
  && make -j ${MAKE_JOBS} install \
  && rm -rf /root/yices2

# Build Verilator.
RUN source /root/dependencies.sh \
  && apt-get install -y git help2man perl python3 make autoconf g++ flex bison ccache \
  && apt-get install -y libgoogle-perftools-dev numactl perl-doc \
  && apt-get install -y libfl2  \
  && apt-get install -y libfl-dev  \
  && mkdir verilator && cd verilator \
  && wget -qO- https://github.com/verilator/verilator/archive/$VERILATOR_COMMIT_HASH.tar.gz | tar xz --strip-components=1 \
  && autoconf \
  && ./configure --prefix="/root/.local" \
  && make -j ${MAKE_JOBS} \
  && make -j ${MAKE_JOBS} install

# Add other Lakeroad files. It's useful to put this as far down as possible. In
# general, only ADD files just before they're needed. This maximizes the ability
# to cache intermediate containers and minimizes rebuilding.
#
# In reality, we use the git functionality of ADD (enabled in our case via the
# optional flag --keep-git-dir) to add all of the checked-in files of the
# Lakeroad repo (but not including the .git directory itself). We could cut this
# down further if we wanted, but I think this is a clean approach for now.
WORKDIR /root/lakeroad
ADD --keep-git-dir=false . .

# Build Racket bytecode; makes Lakeroad much faster.
RUN raco make /root/lakeroad/bin/main.rkt

# Point to lakeroad-private repo. This may or may not exist, if you didn't clone
# the lakeroad-private submodule. However, it shouldn't matter, as anything that
# uses LAKEROAD_PRIVATE_DIR should check if the directory exists/is nonempty first.
ENV LAKEROAD_PRIVATE_DIR=/root/lakeroad/lakeroad-private

# Build Yosys plugin.
WORKDIR /root/lakeroad/yosys-plugin
RUN make -j ${MAKE_JOBS}

WORKDIR /root/lakeroad
CMD [ "/bin/bash", "run-tests.sh" ]
