#!/bin/bash

function getPriority() {
	# TODO put this in a lib to include

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

function install_tmux() {
	local -r tag=$1
	local -r install_prefix=${2:-/usr/local}

	# Build dependencies
	apt-get install -y automake make gcc libevent-dev libncurses5-dev

	# This dependency is required for using the system clipboard:
	apt-get install -y xsel

	# Get the source:
	if [[ ! -d "${install_prefix}/src/tmux" ]]; then
		mkdir -p "${install_prefix}/src"
		cd "${install_prefix}/src"
		git clone https://github.com/tmux/tmux.git
	fi

	cd "${install_prefix}/src/tmux"
	git reset --hard
	git fetch origin
	git checkout "${tag}"
	git pull

	sh autogen.sh      \
		&& ./configure  \
		&& make         \
		&& make install

	local ret=$?
	if [[ "${ret}" == 0 ]]; then
		local -r priority=$(expr $(getPriority tmux) + 1)

		update-alternatives --install /usr/bin/tmux tmux "${install_prefix}/bin/tmux" "${priority}"

	fi
}

install_tmux 3.2

# vim: ts=3 sw=3 sts=0 noet :
