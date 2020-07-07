#!/bin/bash

declare -r VERSION=2.0.2
declare -r INSTALL_PREFIX=/usr/local
declare -r RUN_AS=matt

function install_rofi_pass()
{
  local tag="${1}"
  local install_prefix=${2:-/usr/local}
  local run_as="${3:root}"

  # This script downloads and installs rofi-pass,
  # a rofi front end for passwords stored in pass

  # First, install the build dependencies
  apt-get install -qy make checkinstall xdotool xclip

  # Get the source:
  if [ ! -d "${install_prefix}/src/rofi-pass" ]; then
    mkdir -p "${install_prefix}/src/rofi-pass"
    cd "${install_prefix}/src/rofi-pass"
    chown "${run_as}:${run_as}" "${install_prefix}/src/rofi-pass"
    sudo -H -u "${run_as}" git clone https://github.com/carnager/rofi-pass.git . || exit 1
  fi

  cd "${install_prefix}/src/rofi-pass"
  git pull
  checkinstall -D -y --pkgname rofi-pass --pkgversion "${tag}" --pkggroup x11 make install
}

install_rofi_pass "${VERSION}" "${INSTALL_PREFIX}" "${RUN_AS}"

# vim: ts=2 sw=2 sts=0 expandtab :
