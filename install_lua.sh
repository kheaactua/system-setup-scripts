#!/bin/bash

# This script downloads, builds, and installs lua

function pre_install() {
	apt-get install -y libreadline6-dev
}

declare -r LUA_VERSION=5.3.3

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

pre_install
install_version "${LUA_VERSION}"

# vim: ts=3 sw=3 sts=0 noet :
