#!/bin/bash

declare -r VERSION=master
declare -r INSTALL_PREFIX=/usr/local
declare -r RUN_AS=matt

function install_i3lock_fancy_rapid()
{
  local tag="${1}"
  local install_prefix=${2:-/usr/local}
  local run_as="${3:root}"

  # First, install the build dependencies
  apt install -y \
    git make gcc autoconf automake i3lock libx11-dev

  # Get the source:
  if [ ! -d "${install_prefix}/src/i3lock-fancy-rapid" ]; then
    mkdir -p "${install_prefix}/src"
    cd "${INSTALL_PREFIX}/src"
    git clone https://github.com/yvbbrjdr/i3lock-fancy-rapid -b "${tag}"
    chown -R "${run_as}": "${install_prefix}/src/i3lock-fancy-rapid"
  fi

  cd "${install_prefix}/src/i3lock-fancy-rapid"
  sudo -E -u "${run_as}" make -j
  cp i3lock-fancy-rapid "${install_prefix}/bin/"
  chown root "${install_prefix}/bin/i3lock-fancy-rapid"
}

install_i3lock_fancy_rapid "${VERSION}" "${INSTALL_PREFIX}" "${RUN_AS}"

# vim: ts=2 sw=2 sts=0 expandtab :
