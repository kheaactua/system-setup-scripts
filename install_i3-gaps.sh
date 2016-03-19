#!/bin/bash

# This script downloads, configures, and builds i3-gaps,
# the fork of i3 that allows for gaps between windows

# First, install the build dependencies
apt-get install -y git make gcc checkinstall
apt-get install -y libxcb1-dev libxcb-keysyms1-dev libpango1.0-dev libxcb-util0-dev libxcb-icccm4-dev libyajl-dev libstartup-notification0-dev libxcb-randr0-dev libev-dev libxcb-cursor-dev libxcb-xinerama0-dev libxcb-xkb-dev libxkbcommon-dev libxkbcommon-x11-dev
# Useful packages to use with i3:
apt-get install -y i3lock i3status feh

INSTALL_PREFIX=/usr/local

# Get the source:
if [ ! -d ${INSTALL_PREFIX}/src/i3-gaps ]; then
  mkdir -p ${INSTALL_PREFIX}/src
  git clone https://www.github.com/Airblader/i3 ${INSTALL_PREFIX}/src/i3-gaps
fi

cd ${INSTALL_PREFIX}/src/i3-gaps
git checkout gaps && git pull
make -j && checkinstall -D -y --pkgname i3 --pkgversion 4.12 --pkggroup x11 make install
