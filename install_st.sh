#!/bin/bash -e

declare INSTALL_PREFIX=/usr/local
declare ST_TAG=0.7

# This script downloads, configures, and builds the suckless
# terminal
function install_st() {

	local -r prefix=${1:-/usr/local}
	local -r tag=$2
	local -r gen_new_config=${3:-0}

	# First, install the build dependencies
	local -a pre_reqs=(curl make gcc libxext-dev python-dev libxft-dev libx11-dev x11proto-core-dev libxt-dev)
	for p in ${pre_reqs}; do
		local check_exists=$(dpkg -s $p)
		if [[ "${check_exists}" != 0 ]]; then
			apt-get install -y $p
		fi
	done

	# Get the source:
	cd ${prefix}/src
	if [[ ! -d "st" ]]; then
		git clone http://git.suckless.org/st/
	fi
	cd st

	git fetch
	git checkout ${tag}

	# Generate or download config
	if [[ "${gen_new_config}" == 1 ]]; then
		# Apply patches
		local -a patches

		# Solarized
		# patches+=http://st.suckless.org/patches/solarized/st-solarized-light-0.7.diff
		patches+=http://st.suckless.org/patches/solarized/st-solarized-dark-0.7.diff

		for p in $patches; do
			if [[ ! -e "$(basename $p)" ]]; then
				wget $p
			fi
			patch < $(basename $p)
		done;

		# /Apply Patches
		#

		# Generate a config file
		make
	else
		# Get my custom config from github:
		if [[ ! -e ~/dotfiles/st/config.h ]]; then
			ln -s ~/dotfiles/st/config.h ./
		else
			curl -fLo config.h https://raw.githubusercontent.com/kheaactua/dotfiles/master/st/config.h
		fi
	fi

	if [[ -e config.h ]]; then
		make clean install
	else
		echo "Could not download config.h" >&2
		exit -1;
	fi
}

install_st ${INSTALL_PREFIX} ${ST_TAG}

# vim: ts=3 sw=3 sts=0 noet ffs=unix :
