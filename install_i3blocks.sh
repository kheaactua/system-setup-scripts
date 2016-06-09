#!/bin/bash

# This script downloads, builds, and install i3blocks

# install the required build dependencies:
apt-get install -y ruby-ronn sysstat acpi

INSTALL_PREFIX=/usr/local

# Get the source:
if [ ! -d ${INSTALL_PREFIX}/src/i3blocks-gaps ]; then
  mkdir -p ${INSTALL_PREFIX}/src
  cd ${INSTALL_PREFIX}/src
  git clone https://github.com/Airblader/i3blocks-gaps.git
fi

I3BLOCKS_VERSION=1.4
cd ${INSTALL_PREFIX}/src/i3blocks-gaps
git pull
make -j && checkinstall -D -y --pkgname i3blocks-gaps --pkgversion ${I3BLOCKS_VERSION} --pkggroup x11 make install
