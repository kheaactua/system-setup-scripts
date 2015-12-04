#!/bin/bash

# This script installs i3wm, the tiling window manager,
# and some useful dependencies

# Set up the repo
if [ ! -f /etc/apt/sources.list.d/i3wm.list ]; then
  echo "deb http://debian.sur5r.net/i3/ $(lsb_release -c -s) universe" > /etc/apt/sources.list.d/i3wm.list
  apt-get update
  apt-get --allow-unauthenticated install -y sur5r-keyring
fi

apt-get update
apt-get install -y i3 rxvt-unicode-256color feh
