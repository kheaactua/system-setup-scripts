#!/bin/bash

# This script is used to install a series of tools that
# I use for software development

sudo apt-get install -y   \
    g++              \
    doxygen          \
    graphviz         \
    libpython3-dev   \
    virtualenv       \
    make             \
    build-essential  \
    libssl-dev       \
    dh-autoreconf    \
    pkg-config       \
    libglib2.0-dev   \
    libbz2-dev       \
    pinentry-tty     \
    openssh-server   \
    viewnior         \
    maim             \
    scrot            \
    direnv           \
    plocate          \
    ca-certificates  \
    curl             \
    gnupg2           \
    zsh              \
    shellcheck       \
    libstdc++-12-dev \
    pavucontrol      \
    mscgen           \
    graphviz         \
    asciidoc         \
    doxygen          \
    dia              \

   # ccache           \
   # distcc           \
   # inputplug        \
   # cppcheck         \
   # libglu1-mesa-dev \
   # ninja-build      \
   # libXt            \
   # libXNVCtrl       \
   # libxt-dev        \

function install_nodejs()
{
  sudo mkdir -p /etc/apt/keyrings
  curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg

  NODE_MAJOR=20
  echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list

  sudo apt-get update
  sudo apt-get install nodejs -y
}

install_nodejs

echo "Install the dracula theme, and also https://github.com/Gogh-Co/Gogh#%EF%B8%8F-pre-install"

themes=(pali solarized-light solarized-dark ayu elemental lunaria-eclipse relaxed rose-pine-dawn rose-pine-moon synthwave-alpha zenburn)

# vim: ts=3 ts=3 sts=0 expandtab ft=sh ffs=unix :
