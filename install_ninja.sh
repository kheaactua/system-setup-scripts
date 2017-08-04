#!/bin/bash

source getPriority.sh

function install_ninja() {

	local -r TAG=$1

	local -r INSTALL_PREFIX=/usr/local

	# Get the source:
	if [[ ! -d "${INSTALL_PREFIX}/src/ninja" ]]; then
		mkdir -p "${INSTALL_PREFIX}/src"
		cd "${INSTALL_PREFIX}/src"
		git clone https://github.com/ninja-build/ninja.git
	fi

	cd "${INSTALL_PREFIX}/src/ninja"
	git fetch
	git checkout ${TAG}
	git pull

	./configure.py --bootstrap

	local ret=$?
	if [[ "${ret}" == 0 ]]; then
		local -r priority=$(expr $(getPriority ninja) + 1)

		update-alternatives --install /usr/bin/ninja ninja ${INSTALL_PREFIX}/src/ninja/ninja ${priority}

	fi
}

install_ninja v1.7.2

# vim: ts=3 sw=3 sts=0 noet :
