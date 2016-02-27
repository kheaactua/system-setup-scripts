#!/bin/bash

# This script sets up a PPA to install the latest
# version of tmux. The one that ships with Ubuntu
# 14.04 is too old to use plugins with.

# Build dependencies
apt-get install -y automake make gcc libevent-dev

# This dependency is required for using the system clipboard:
apt-get install -y xsel

INSTALL_PREFIX=/usr/local

# Get the source:
if [ ! -d ${INSTALL_PREFIX}/src/tmux ]; then
  mkdir -p ${INSTALL_PREFIX}/src
  cd ${INSTALL_PREFIX}/src
  git clone https://github.com/tmux/tmux.git
fi

cd ${INSTALL_PREFIX}/src/tmux
git pull
sh autogen.sh
./configure && make
