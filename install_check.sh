#!/bin/bash

declare -r VERSION=0.15.2
declare -r INSTALL_PREFIX=/usr/local
declare -r RUN_AS=matt

function install_check()
{
  local tag="${1}"
  local install_prefix=${2:-/usr/local}
  local run_as="${3:root}"

  # First, install the build dependencies
  apt install -y \
    git make gcc checkinstall autoconf automake pkg-config texinfo

  # Get the source:
  if [ ! -d "${install_prefix}/src/check" ]; then
    mkdir -p "${install_prefix}/src"
    cd "${INSTALL_PREFIX}/src"
    git clone --recursive https://github.com/libcheck/check.git
    chown -R "${run_as}": "${install_prefix}/src/check"
  fi

  cd "${install_prefix}/src/check"
  sudo -E -u "${run_as}" git fetch --tags
  sudo -E -u "${run_as}" git checkout "${tag}"
  sudo -E -u "${run_as}" cmake -Bbuild -H. \
    && sudo -E -u "${run_as}" cmake --build build \
    && cmake --install build
}

install_check "${VERSION}" "${INSTALL_PREFIX}" "${RUN_AS}"

# vim: ts=2 sw=2 sts=0 expandtab :
