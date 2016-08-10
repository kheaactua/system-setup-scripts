#!/bin/bash

# This script is used to install a series of tools that
# I use for software development

apt-get install -y g++ \
   clang            \
   ccache           \
   distcc           \
   doxygen          \
   graphviz         \
   libpython-dev    \
   cppcheck         \
   cmake            \
   cmake-curses-gui \
   cmake-qt-gui     \
   make             \
   ninja-build      \
   build-essential  \
   libXt            \
   libxt-dev        \
   libXNVCtrl       \
   libglu1-mesa-dev \
   libssl-dev       \
   dh-autoreconf    \
   pkg-config       \
   libglib2.0-dev   \
   libbz2-dev       \
   inputplug        \
   python-rosdep python-rosinstall-generator python-wstool python-rosinstall \


# vim: ts=3 st=3 sts=0 expandtab ft=sh ffs=unix :
