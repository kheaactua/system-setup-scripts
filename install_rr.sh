#!/bin/sh

# This script installs rr, the deterministic debugger.

# First install the build dependencies:
sudo apt-get -y install ccache cmake make g++-multilib gdb \
  pkg-config libz-dev realpath python-pexpect manpages-dev git zlib1g-dev \
  ninja-build checkinstall

INSTALL_PREFIX=/usr/local

# Get the source:
if [ ! -d ${INSTALL_PREFIX}/src/rr ]; then
  mkdir -p ${INSTALL_PREFIX}/src
  git clone https://github.com/mozilla/rr.git ${INSTALL_PREFIX}/src/rr
fi

RR_VERSION=4.2.0
cd ${INSTALL_PREFIX}/src/rr
git fetch --tags
git checkout ${RR_VERSION}
mkdir -p build && cd build
cmake ..
make -j && checkinstall -D -y --pkgname rr --pkgversion ${RR_VERSION} make install

