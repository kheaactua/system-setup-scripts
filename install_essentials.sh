#!/bin/bash

# This script is used to install a series of packages that
# I consider essential for me to have on a Linux computer.

apt-get install -y python-software-properties \
  vim \
  git \
  htop \
  openssh-server \
  zsh \
  autossh \
  curl \
  cifs-utils \
  xsel \
  pass \
  silversearcher-ag \
  stow \
  unzip
