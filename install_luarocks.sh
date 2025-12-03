#!/bin/bash

# This script downloads, builds, and installs lua

function pre_install() {
	apt-get install -y build-essential libreadline-dev unzip
}

declare -r LUAROCKS_VERSION=3.9.2
declare -r INSTALL_PREFIX=/usr/local

function install_luarocks() {

	local -r v=${1:-${LUAROCKS_VERSION}}
	local -r src="${INSTALL_PREFIX}/src"

	# Get the source
	cd "${src}" && chown matt "${src}"
	sudo -u matt wget https://luarocks.org/releases/luarocks-${LUAROCKS_VERSION}.tar.gz
	sudo -u matt tar xapf luarocks-${LUAROCKS_VERSION}.tar.gz

	# Enter the directory
	cd "luarocks-${v}"
	pwd
	sudo -u matt ./configure \
		--prefix=/usr/local \
		--with-lua-include=/usr/local/include \
		--with-lua-bin=$(dirname $(which lua)) \
		&& sudo -u make \
		&& make install
}

# pre_install

# Is it already installed?
declare installed_version=$(luarocks --version | sed 's/.*\([[:digit:]]\.[[:digit:]]\.[[:digit:]]\).*/\1/')
if [[ "${installed_version}" == "${LUAROCKS_VERSION}" && "$1" != "force" ]]; then
	echo "${LUAROCKS_VERSION} already installed at $(which luarocks)"
else
	# install_luarocks "${LUAROCKS_VERSION}"
	echo "Why not use brew install luarocks"
fi

# vim: ts=3 sw=3 sts=0 noet :
