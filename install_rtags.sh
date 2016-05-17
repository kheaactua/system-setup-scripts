#!/bin/bash

# This script downloads, builds, and installs rtags

# Do we have clang?
./install_clang.sh
if [[ $? != 0 ]]; then
	echo "Could not install clang, existing." 2>&1 /dev/null
fi

CLANG_VERSION=$(realpath /etc/alternatives/clang | sed 's/.*\([[:digit:]]\.[[:digit:]]\).*/\1/')
# Default this just incase
CLANG_VERSION=${clang_version:-3.8}

INSTALL_PREFIX=/usr/local

# Get the source:
if [[ ! -d "${INSTALL_PREFIX}/src/rtags" ]]; then
	mkdir -p "${INSTALL_PREFIX}/src/rtags"
	cd "${INSTALL_PREFIX}/src"
	git clone https://github.com/Andersbakken/rtags.git
	cd "${INSTALL_PREFIX}/src/rtags"
	git submodule init
	mkdir -p "${INSTALL_PREFIX}/src/rtags/build"
fi

cd "${INSTALL_PREFIX}/src/rtags"
git pull
git submodule update
cd "${INSTALL_PREFIX}/src/rtags/build"

# Ensure realpath is installed
apt-get install -y realpath

# Build and install the source:
CXX=clang++-${CLANG_VERSION} cmake -GNinja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} -DLIBCLANG_LLVM_CONFIG_EXECUTABLE=/usr/bin/llvm-config-${CLANG_VERSION} .. && ninja install

# vim: ts=3 sw=3 sts=0 noet :
