#!/bin/bash

# Set up a PPA to install the latest
# version of tmux. The one that ships with Ubuntu
# 14.04 is too old to use plugins with.
function install_tmux() {

	local -r TAG=$1

	# Build dependencies
	apt-get install -y automake make gcc libevent-dev libncurses5-dev

	# This dependency is required for using the system clipboard:
	apt-get install -y xsel

	local -r INSTALL_PREFIX=/usr/local

	# Get the source:
	if [[ ! -d "${INSTALL_PREFIX}/src/tmux" ]]; then
		mkdir -p "${INSTALL_PREFIX}/src"
		cd "${INSTALL_PREFIX}/src"
		git clone https://github.com/tmux/tmux.git
	fi

	cd "${INSTALL_PREFIX}/src/tmux"
	git checkout ${TAG}
	git pull

	sh autogen.sh      \
		&& ./configure  \
		&& make         \
		&& make install
}

install_tmux 2.2

# vim: ts=3 sw=3 sts=0 noet :
