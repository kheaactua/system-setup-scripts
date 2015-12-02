#!/bin/bash

# This script downloads, builds, and install i3blocks

# install the required build dependencies:
apt-get update
apt-get install -y ruby-ronn sysstat acpi

# Get the source:
if [ ! -f /usr/local/bin/i3blocks ]; then
  mkdir -p ~/git
  cd ~/git
  if [ ! -d ~/git/i3blocks ]; then
    git clone https://github.com/vivien/i3blocks.git
  fi
fi

cd ~/git/i3blocks
make install
