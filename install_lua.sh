#!/bin/bash

# This script downloads, builds, and installs lua

function pre_install() {
	sudo apt-get install -y build-essential libreadline-dev unzip
}

declare -r LUA_VERSION=5.4.8
declare -r INSTALL_PREFIX=/usr/local

function install_version() {

	local -r v=${1:-${LUA_VERSION}}
	local -r src="${INSTALL_PREFIX}/src"

	# Get the source
	cd "${src}" && chown matt "${src}"
	sudo -u matt curl -R -O http://www.lua.org/ftp/lua-${v}.tar.gz
	sudo -u matt tar zxf "lua-${v}.tar.gz"

	# Enter the directory
	cd lua-${v}
	sudo -u matt make linux test && make install
}

# pre_install

# Is it already installed?
declare installed_version
if command -v lua &> /dev/null; then
	installed_version=$(lua -v | sed 's/.*\([[:digit:]]\.[[:digit:]]\.[[:digit:]]\).*/\1/')
else
	installed_version=""
fi
if [[ "${installed_version}" == "${LUA_VERSION}" && "$1" != "force" ]]; then
	echo "${LUA_VERSION} already installed at $(which lua)"
else
	# install_version "${LUA_VERSION}"
	echo "Maybe just use brew install lua@5.4"
fi

# vim: ts=3 sw=3 sts=0 noet :
