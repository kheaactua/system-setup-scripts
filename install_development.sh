#!/bin/bash

# This script is used to install a series of tools that
# I use for software development

apt-get install -y   \
    g++              \
    ccache           \
    distcc           \
    doxygen          \
    graphviz         \
    libpython-dev    \
    cppcheck         \
    make             \
    build-essential  \
    libglu1-mesa-dev \
    libssl-dev       \
    dh-autoreconf    \
    pkg-config       \
    libglib2.0-dev   \
    libbz2-dev       \
    inputplug        \

   # ninja-build      \
   # libXt            \
   # libXNVCtrl       \
   # libxt-dev        \

# vim: ts=3 ts=3 sts=0 expandtab ft=sh ffs=unix :
