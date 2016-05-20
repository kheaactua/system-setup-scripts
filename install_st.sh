#!/bin/bash -e


declare -r INSTALL_PREFIX=/usr/local
declare -r ST_VERSION=0.6

# This script downloads, configures, and builds the suckless
# terminal
function install_st() {

	local -r prefix=$1
	local -r version=$2
	local -r force=${3:-0}

	# First, install the build dependencies
	apt-get install -y libxft-dev curl make gcc libxext-dev


	# Get the source:
	if [[ ! -d "${prefix}/src/st-${version}" && "${force}" != "1" ]]; then
		curl -fLo /tmp/st-${version}.tar.gz http://dl.suckless.org/st/st-0.6.tar.gz
		mkdir -p ${prefix}/src
		cd ${prefix}/src && tar xvzf /tmp/st-${version}.tar.gz
	fi

	# Get my custom config from github:
	curl -fLo ${prefix}/src/st-${version}/config.h https://raw.githubusercontent.com/kheaactua/dotfiles/master/st/config.h

	cd ${prefix}/src/st-${version}
	make clean install
}

install_st ${INSTALL_PREFIX} ${ST_VERSION}

# vim: ts=3 sw=3 sts=0 noet ffs=unix :
