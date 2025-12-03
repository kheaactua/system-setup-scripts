#!/bin/bash

# This script is used to install a series of packages that
# I consider essential for me to have on a Linux computer.

sudo apt-get install -qy \
  software-properties-common \
  htop \
  openssh-server \
  zsh \
  curl \
  xsel \
  pass \
  stow \
  locate \
  wget \
  gettext \
  python3-venv \
  build-essential \
  checkinstall \
  jq \
  gpgconf gpgv2 \
  unzip \
  && sudo apt autoremove -qy

  # These all have better installers
  # environment-modules \
  # ripgrep \
  # fd-find \
  # cargo \

# Upgrade git and repo
sudo apt-get install -qy software-properties-common \
  && sudo add-apt-repository ppa:git-core/ppa     \
  && sudo apt-get update                          \
  && sudo apt-get install -qy git git-core git-lfs git-man

sudo -u matt "$(which cargo)" install exa dust ytop bat sd
sudo -u matt "$(which brew)" install lua luarocks tmux gh
