#!/bin/bash

# This script is used to install a series of packages that
# I consider essential for me to have on a Linux computer.

apt-get install -qy \
  software-properties-common \
  git \
  htop \
  openssh-server \
  zsh \
  curl \
  xsel \
  pass \
  stow \
  environment-modules \
  ripgrep \
  fd-find \
  cargo \
  locate \
  wget \
  gettext \
  python3-venv \
  build-essential \
  checkinstall \
  jq \
  gpgconf gpgv2 \
  unzip

# Upgrade git and repo
apt-get install -qy software-properties-common \
  && add-apt-repository ppa:git-core/ppa     \
  && apt-get update                          \
  && apt-get install -qy git git-core git-lfs git-man

sudo -u matt cargo install exa dust ytop bat sd

./install_lua.sh
./install_tmux.sh
./install_neovim.sh
./install_check.sh
./install_i3.sh
