#!/bin/bash

declare -r VERSION=1.6.1
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
    bison flex i3-wm libasound2-dev libcairo2-dev libcurl4-openssl-dev \
    libev-dev libglib2.0-dev libiw-dev libmpdclient-dev libpam0g-dev \
    libpango1.0-dev libpangocairo-1.0-0 libpulse-dev librsvg2-dev \
    libstartup-notification0-dev libx11-dev libxcb-composite0-dev \
    libxcb-dpms0-dev libxcb-ewmh-dev libxcb-ewmh2 libxcb-icccm4-dev \
    libxcb-image0-dev libxcb-randr0-dev libxcb-util-dev libxcb-util0-dev \
    libxcb-xinerama0-dev libxcb-xkb-dev libxcb-xrm-dev libxcb1-dev libxft-dev \
    libxinerama-dev libxkbcommon-dev libxkbcommon-x11-0 libxkbcommon-x11-dev \
    libxkbfile-dev python3-xcbgen xcb xcb-proto

  # Get the source:
  if [ ! -d "${install_prefix}/src/rofi" ]; then
    mkdir -p "${install_prefix}/src"
    cd "${INSTALL_PREFIX}/src"
    git clone --recursive https://github.com/DaveDavenport/rofi.git
    chown -R "${run_as}": "${install_prefix}/src/rofi"
  fi

  cd "${install_prefix}/src/rofi"
  sudo -E -u "${run_as}" git fetch --tags
  sudo -E -u "${run_as}" git checkout "${tag}"
  sudo -E -u "${run_as}" autoreconf -i
  sudo -E -u "${run_as}" mkdir -p build && cd build
  sudo -E -u "${run_as}" ../configure --prefix="${install_prefix}" --enable-drun
  sudo -E -u "${run_as}" make -j \
    && checkinstall -D -y --pkgname rofi --pkgversion "${tag}" --pkggroup x11 make install
}

install_rofi "${VERSION}" "${INSTALL_PREFIX}" "${RUN_AS}"

# vim: ts=2 sw=2 sts=0 expandtab :
