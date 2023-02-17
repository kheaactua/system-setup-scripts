#!/bin/bash

# This script downloads, builds, and installs lua

function pre_install() {
	apt-get install -y build-essential libreadline-dev unzip
}

declare -r LUA_VERSION=5.4.4
declare -r INSTALL_PREFIX=/usr/local

function install_version() {

	local -r v=${1:-${LUA_VERSION}}
	local -r src="${INSTALL_PREFIX}/src"

	# Get the source
	cd "${src}"
	curl -R -O http://www.lua.org/ftp/lua-${v}.tar.gz
	tar zxf lua-${v}.tar.gz

	# Enter the directory
	cd lua-${v}
	make linux test && make install
}

# pre_install

# Is it already installed?
declare installed_version=$(lua -v | sed 's/.*\([[:digit:]]\.[[:digit:]]\.[[:digit:]]\).*/\1/')
if [[ "${installed_version}" == "${LUA_VERSION}" && "$1" != "force" ]]; then
	echo "${LUA_VERSION} already installed at $(which lua)"
else
	install_version "${LUA_VERSION}"
fi

# vim: ts=3 sw=3 sts=0 noet :
