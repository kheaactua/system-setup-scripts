#!/bin/bash

# This script downloads, builds, and installs rtags

# First, check if we have the correct sources for the newest version of
# clang:
CLANG_VERSION=3.8
if [ ! -f /etc/apt/sources.list.d/llvm.list ]; then
  wget -O - http://llvm.org/apt/llvm-snapshot.gpg.key|apt-key add -
  echo "deb http://llvm.org/apt/trusty/ llvm-toolchain-trusty-${CLANG_VERSION} main" > /etc/apt/sources.list.d/llvm.list
  echo "deb-src http://llvm.org/apt/trusty/ llvm-toolchain-trusty-${CLANG_VERSION} main" >> /etc/apt/sources.list.d/llvm.list
fi

# install the required build dependencies:
apt-get update
apt-get install -y cmake ninja-build clang-${CLANG_VERSION} libclang-${CLANG_VERSION}-dev libclang-common-${CLANG_VERSION}-dev libclang1-${CLANG_VERSION} libllvm${CLANG_VERSION} libncurses5-dev libssl-dev git g++

INSTALL_PREFIX=/usr/local

# Get the source:
if [ ! -d ${INSTALL_PREFIX}/src/rtags ]; then
  mkdir -p ${INSTALL_PREFIX}/src/rtags
  cd ${INSTALL_PREFIX}/src
  git clone https://github.com/Andersbakken/rtags.git
  cd ${INSTALL_PREFIX}/src/rtags
  git submodule init
  mkdir -p ${INSTALL_PREFIX}/src/rtags/build
fi

cd ${INSTALL_PREFIX}/src/rtags
git pull
git submodule update
cd ${INSTALL_PREFIX}/src/rtags/build

# Build and install the source:
CXX=clang++-${CLANG_VERSION} cmake -GNinja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} -DLIBCLANG_LLVM_CONFIG_EXECUTABLE=/usr/bin/llvm-config-${CLANG_VERSION} .. && ninja install

