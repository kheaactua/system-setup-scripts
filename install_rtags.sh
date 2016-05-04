#!/bin/bash

# This script downloads, builds, and installs rtags

# Do we have clang?
./install_clang.sh

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
git submodule update
cd ${INSTALL_PREFIX}/src/rtags/build

# Ensure realpath is installed
apt-get install -y realpath

clang_version=$(realpath /etc/alternatives/clang | sed 's/.*\([[:digit:]]\.[[:digit:]]\).*/\1/')
# Default this just incase
clang_version=${clang_version:-3.8}

# Build and install the source:
CXX=clang++-${clang_version} cmake -GNinja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} -DLIBCLANG_LLVM_CONFIG_EXECUTABLE=/usr/bin/llvm-config-${clang_version} .. && ninja install

# vim: ts=3 sw=3 sts=0 noet :
