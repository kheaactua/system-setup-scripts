#!/bin/bash
# shellcheck disable=SC2086,SC2154,SC2155

declare -r RUN_AS=matt

# I don't think this works very well.
# And there was an issue with v4l-utils doc/html wasn't found.  I had to manually build it and copy it to the original build location

function install_wlroot()
{

  local install_prefix=${1:-/usr/local}
  local run_as="${2:-${RUN_AS}}"

  sudo apt-get install -qy wayland-protocols \
    libwayland-dev \
    libegl1-mesa-dev \
    libgles2-mesa-dev \
    libdrm-dev \
    libgbm-dev \
    libinput-dev \
    libxkbcommon-dev \
    libgudev-1.0-dev \
    libpixman-1-dev \
    libsystemd-dev \
    cmake \
    libpng-dev \
    libavutil-dev \
    libavcodec-dev \
    libavformat-dev \
    ninja-build \
    meson

  sudo apt-get install -qy libxcb-composite0-dev \
    libxcb-icccm4-dev \
    libxcb-image0-dev \
    libxcb-render0-dev \
    libxcb-xfixes0-dev \
    libxkbcommon-dev \
    libxcb-xinput-dev \
    libx11-xcb-dev

  local wlroots_src_dir="${install_prefix}/src/wlroots"

  # Get the source:
  if [ ! -d "${wlroots_src_dir}" ]; then
    mkdir -p "$(dirname "${wlroots_src_dir}")"
    cd "$(dirname "${wlroots_src_dir}")"
    git clone https://gitlab.freedesktop.org/wlroots/wlroots.git "${wlroots_src_dir}"
    cd "${wlroots_src_dir}"

    # TODO not sure I should specify a tag
    git checkout 0.19.1
    chown -R "${run_as}": "${wlroots_src_dir}"
  fi

  cd "${wlroots_src_dir}"
  sudo -E -u "${run_as}" meson bld \
    && sudo -E -u "${run_as}" ninja -C bld \

    # && ninja -C bld install
}

function install_sway()
{
  set -e

  local install_prefix=${1:-/usr/local}
  local run_as="${2:-${RUN_AS}}"

  sudo apt-get install -qy libjson-c-dev \
    libpango1.0-dev \
    libcairo2-dev \
    libgdk-pixbuf2.0-dev \
    scdoc

  local repo="swaywm/sway"
  set -x
  local api_url="https://api.github.com/repos/$repo/releases/latest"

  # Get the latest release download URL for the source tarball
  local download_url=$(curl -s "$api_url" | grep "tarball_url" | cut -d '"' -f 4)

  # Where to download the file
  local local_download="${install_prefix}/src/sway/$(basename "${download_url}").tar.gz"

  local -r sway_src_dir="${install_prefix}/src/sway/$(basename "${local_download}" .tar.gz)"
  set +x

  echo "Latest release artifact: $(basename "${download_url}"), downloading to ${local_download}"

  # Get the source
  if [ ! -d "${sway_src_dir}" ]; then
    mkdir -p "${sway_src_dir}"

    if [ ! -e "${local_download}" ]; then
      # Download the tarball
      curl -L -o "${local_download}" "${download_url}"
      tar -xzvf "${local_download}" --strip-components=1 -C "${sway_src_dir}"
    fi

    mkdir subprojects
    install_wlroot "${sway_src_dir}/subprojects/wlroot" "${run_as}"

    chown -R "${run_as}": "${sway_src_dir}"
  fi

  # This also takes a newer libinput, I used this ppa:
  # https://launchpad.net/~ubuntuhandbook1/+archive/ubuntu/libinput-4fg

  cd "${sway_src_dir}"
  sudo -E -u "${run_as}" meson bld \
    && sudo -E -u "${run_as}" ninja -C bld \
    && ninja -C bld install

  set +e
}

# install_wlroot
install_sway

# vim: ts=2 sw=2 sts=0 expandtab :
