#!/bin/bash

# This script is used to install a series of tools that
# I use for software development

apt-get install -y   \
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
    scrot             \
    zsh              \

   # ccache           \
   # distcc           \
   # inputplug        \
   # cppcheck         \
   # libglu1-mesa-dev \
   # ninja-build      \
   # libXt            \
   # libXNVCtrl       \
   # libxt-dev        \

# vim: ts=3 ts=3 sts=0 expandtab ft=sh ffs=unix :
