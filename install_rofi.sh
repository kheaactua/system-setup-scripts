#!/bin/bash

declare -r VERSION=1.5.4
declare -r INSTALL_PREFIX=/usr/local
declare -r RUN_AS=matt

function install_rofi()
{
  local tag="${1}"
  local install_prefix=${2:-/usr/local}
  local run_as="${3:root}"

  # This script downloads, configures, and builds rofi,
  # a window launcher that can be used with i3 instead of
  # demnu

  # First, install the build dependencies
  apt install -qy \
    git make gcc checkinstall autoconf automake pkg-config
  apt install -qy \
    libxinerama-dev libxft-dev libpango1.0-dev libcairo2-dev \
    libpangocairo-1.0-0 libglib2.0-dev libx11-dev libstartup-notification0-dev \
    bison flex libxkbcommon-x11-0 libxkbcommon-dev libxkbcommon-x11-dev \
    librsvg2-dev libev-dev libpam0g-dev libxcb-dpms0-dev libxkbfile-dev \

  # Get the source:
  if [ ! -d "${install_prefix}/src/rofi" ]; then
    mkdir -p "${install_prefix}/src"
    cd "${INSTALL_PREFIX}/src"
    git clone --recursive https://github.com/DaveDavenport/rofi.git
    chown -R "${run_as}": "${install_prefix}/src/rofi"
  fi

  cd "${install_prefix}/src/rofi"
  sudo -u "${run_as}" git fetch --tags
  sudo -u "${run_as}" git checkout "${tag}"
  sudo -u "${run_as}" autoreconf -i
  sudo -u "${run_as}" mkdir -p build && cd build
  sudo -u "${run_as}" ../configure --prefix="${install_prefix}" --enable-drun
  sudo -u "${run_as}" make -j \
    && checkinstall -D -y --pkgname rofi --pkgversion "${tag}" --pkggroup x11 make install
}

install_rofi "${VERSION}" "${INSTALL_PREFIX}" "${RUN_AS}"

# vim: ts=2 sw=2 sts=0 expandtab :
