#!/bin/bash

declare -r VERSION=1.5.4
declare -r INSTALL_PREFIX=/usr/local

function install_rofi()
{
  local tag="${1}"
  local install_prefix=${2:-/usr/local}

  # This script downloads, configures, and builds rofi,
  # a window launcher that can be used with i3 instead of
  # demnu

  # First, install the build dependencies
  apt install -y \
    git make gcc checkinstall autoconf automake pkg-config
  apt install -y \
    libxinerama-dev libxft-dev libpango1.0-dev libcairo2-dev libpangocairo-1.0-0 libglib2.0-dev libx11-dev libstartup-notification0-dev


  # Get the source:
  if [ ! -d "${install_prefix}/src/rofi" ]; then
    mkdir -p "${install_prefix}/src"
    cd "${INSTALL_PREFIX}/src"
    git clone https://github.com/DaveDavenport/rofi.git
  fi

  ROFI_VERSION=1.5.4
  cd "${install_prefix}/src/rofi"
  git fetch --tags
  git checkout "${tag}"
  autoreconf -i
  mkdir -p build && cd build
  ../configure
  make -j && checkinstall -D -y --pkgname rofi --pkgversion "${tag}" --pkggroup x11 make install
}

install_rofi "${VERSION}" "${INSTALL_PREFIX}"

# vim: ts=2 sw=2 sts=0 expandtab :
