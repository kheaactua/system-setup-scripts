#!/bin/bash

declare -r VERSION=latest
declare -r INSTALL_PREFIX=/usr/local
declare -r RUN_AS=matt

function install_i3_gaps()
{
  set -e
  local tag="${1}"
  local install_prefix=${2:-/usr/local}
  local run_as="${3:-matt}"

  # This script downloads, configures, and builds i3-gaps

  sudo apt-get install -qy meson dh-autoreconf libxcb-keysyms1-dev libpango1.0-dev libxcb-util0-dev xcb libxcb1-dev libxcb-icccm4-dev libyajl-dev libev-dev libxcb-xkb-dev libxcb-cursor-dev libxkbcommon-dev libxcb-xinerama0-dev libxkbcommon-x11-dev libstartup-notification0-dev libxcb-randr0-dev libxcb-xrm0 libxcb-xrm-dev libxcb-shape0 libxcb-shape0-dev

  local -r pkg=$(mktemp -d)

  curl -sH "Accept: application/vnd.github.v3+json" https://api.github.com/repos/Airblader/i3/releases/latest > "${pkg}/pkg.json"

  local -r tarball_url=$(cat ${pkg}/pkg.json | jq -j '.tarball_url')
  local -r tag_name=$(cat ${pkg}/pkg.json | jq -j '.tag_name')
  local -r tar_file="${pkg}/src.tgz"

  curl -sL --output "${tar_file}" "${tarball_url}"

  # Get the source:
  if [ ! -d "${install_prefix}/src/i3-gaps" ]; then
    mkdir -p "${install_prefix}/src/i3-gaps"
    cd "${install_prefix}/src/i3-gaps"
  fi

  if [[ -e "${install_prefix}/src/i3-gaps/${tag_name}" ]]; then
    rm -rf "${install_prefix}/src/i3-gaps/${tag_name}"
  fi
  mkdir -p "${install_prefix}/src/i3-gaps/${tag_name}/build"
  tar -xz --strip-components=1 -C "${install_prefix}/src/i3-gaps/${tag_name}" -f "${tar_file}"

  chown -R "${run_as}": "${install_prefix}/src/i3-gaps"

  cd "${install_prefix}/src/i3-gaps/${tag_name}/build"

  sudo -E -u "${run_as}" meson --prefix "${install_prefix}"
  sudo -E -u "${run_as}" CCACHE_DIR=/opt/ccache ninja \
    && checkinstall -D -y --pkgname i3-gaps --pkgversion "${tag_name}" --pkggroup x11 ninja install
}

install_i3_gaps "${1:-${VERSION}}" "${INSTALL_PREFIX}" "${RUN_AS}"

# vim: ts=2 sw=2 sts=0 expandtab :
