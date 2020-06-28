#!/bin/bash

declare -r VERSION=3.4.3
declare -r INSTALL_PREFIX=/usr/local

function install_polybar()
{
  local tag="${1}"
  local install_prefix=${2:-/usr/local}

  # This script downloads, configures, and builds rofi,
  # a window launcher that can be used with i3 instead of
  # demnu

  # First, install the build dependencies
  if [[ "0" == "$(id -u)" ]]; then
    apt install -qy \
      git gcc checkinstall autoconf automake pkg-config \
      ccache cmake ninja-build  \
      cmake-data libxcb1-dev libxcb-ewmh-dev \
      libxcb-icccm4-dev libxcb-image0-dev libxcb-randr0-dev \
      libxcb-util0-dev libxcb-xkb-dev pkg-config python-xcbgen \
      xcb-proto libxcb-xrm-dev i3-wm libasound2-dev libmpdclient-dev \
      libiw-dev libcurl4-openssl-dev libpulse-dev \
      libxcb-composite0-dev xcb libxcb-ewmh2
  else
    echo "Skipping installing dependencies"
  fi

  # Get the source:
  if [ ! -d "${install_prefix}/src/polybar" ]; then
    mkdir -p "${install_prefix}/src"
    cd "${INSTALL_PREFIX}/src"
    git clone https://github.com/polybar/polybar.git
  fi

  ROFI_VERSION=1.5.4
  cd "${install_prefix}/src/polybar"
  git submodule update --init
  git fetch --tags
  git checkout "${tag}"
  cmake -Bbuild -H. -GNinja \
    && cmake --build build \
    && if [[ "0" == "$(id -u)" ]]; then
      cmake --install build
    else
      echo "Please run cmake --install"
    fi
}

install_polybar "${VERSION}" "${INSTALL_PREFIX}"

# vim: ts=2 sw=2 sts=0 expandtab :
