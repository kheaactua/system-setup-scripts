#!/bin/bash

# This script downloads and installs rofi-pass,
# a rofi front end for passwords stored in pass

# First, install the build dependencies
apt-get install -y make checkinstall
apt-get install -y xdotool xclip

INSTALL_PREFIX=/usr/local
ROFI_PASS_VERSION=1.3.1

# Get the source:
if [ ! -d ${INSTALL_PREFIX}/src/rofi-pass ]; then
  mkdir -p ${INSTALL_PREFIX}/src
  cd ${INSTALL_PREFIX}/src
  git clone https://github.com/carnager/rofi-pass.git 
fi

cd ${INSTALL_PREFIX}/src/rofi-pass
git pull
checkinstall -D -y --pkgname rofi-pass --pkgversion ${ROFI_PASS_VERSION} --pkggroup x11 make install
