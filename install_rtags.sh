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

# Build and install the source:
CXX=clang++-3.8 cmake -GNinja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} -DLIBCLANG_LLVM_CONFIG_EXECUTABLE=/usr/bin/llvm-config-3.8 .. && ninja install

# vim: ts=3 sw=3 sts=0 noet :
