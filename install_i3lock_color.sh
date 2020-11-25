#!/bin/bash

declare -r VERSION=master
declare -r INSTALL_PREFIX=/usr/local
declare -r RUN_AS=matt

function install_i3lock_color()
{
  local tag="${1}"
  local install_prefix=${2:-/usr/local}
  local run_as="${3:root}"

  # First, install the build dependencies
  apt install -qy libjpeg-dev

  # Get the source:
  if [ ! -d "${install_prefix}/src/i3lock-color" ]; then
    mkdir -p "${install_prefix}/src"
    cd "${INSTALL_PREFIX}/src"
    git clone https://github.com/Raymo111/i3lock-color.git
    chown -R "${run_as}": "${install_prefix}/src/i3lock-color"
  fi

  cd "${install_prefix}/src/i3lock-color"
  # sudo -E -u "${run_as}" ./build.sh
  chmod +x install-i3lock-color.sh

  sed -i "s#--prefix=/usr#--prefix=${install_prefix}#" install-i3lock-color.sh
  ./install-i3lock-color.sh
}

install_i3lock_color "${VERSION}" "${INSTALL_PREFIX}" "${RUN_AS}"

# vim: ts=2 sw=2 sts=0 expandtab :
