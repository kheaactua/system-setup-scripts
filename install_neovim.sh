#!/bin/bash

function getPriority() {
	# Which alternative target name to query
	local -r bin=$1

	query=$(update-alternatives --display $bin | \
		grep priority                   | \
		cut -d' ' -f 4                  | \
		sort                            | \
		tail -n 1                         \
	)
	echo $query
}

# This script sets up a PPA and installs
# neovim.
function install_neovim() {

	# See if neovim is already installed:
	if hash nvim 2>/dev/null; then
	  echo "Neovim already installed"
	 exit 0
	fi

	# The following dependencies are required for
	# python support in neovim:
	apt-get install -y python-dev python-pip python3-dev python3-pip

	apt-get update
	apt-get install -y neovim

	# This dependency is require for using the system clipboard:
	which xsel > /dev/null || apt-get install -y xsel

	# Then install the python modules:
	pip2 install neovim                                                         \
		&& pip3 install neovim                                                   \
		&& update-alternatives --install /usr/bin/vi     vi     /usr/bin/nvim 60 \
		&& update-alternatives --install /usr/bin/vim    vim     /usr/bin/nvim 60 \
		&& update-alternatives --install /usr/bin/editor vim     /usr/bin/nvim 60
}

install_neovim

# vim: ts=3 sw=3 sts=0 noet :
