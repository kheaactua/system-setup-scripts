#!/bin/bash

# This script sets up a PPA to install the latest
# version of tmux. The one that ships with Ubuntu
# 14.04 is too old to use plugins with.

if [ ! -f /etc/apt/sources.list.d/pi-rho-dev-trusty.list ]; then
  add-apt-repository -y ppa:pi-rho/dev
fi

apt-get update
apt-get install -y tmux

# This dependency is require for using the system clipboard:
apt-get install -y xsel
