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

function install_gdb() {

	local -r TAG=$1
	local -r INSTALL_PREFIX=/usr/local

	which bison > /dev/null 2>&1
	if [[ $? != 0 ]]; then
		sudo apt-get -qy install bison
	fi

	which flex > /dev/null 2>&1
	if [[ $? != 0 ]]; then
		sudo apt-get -qy install flex
	fi

	# sudo apt-get -qy install libmpfrc++-dev libgmp3-dev

	# Get the source:
	if [[ ! -d "${INSTALL_PREFIX}/src/gdb" ]]; then
		sudo mkdir -p "${INSTALL_PREFIX}/src"
		sudo chown -R $(whoami):$(whoami) "${INSTALL_PREFIX}/src"
		cd "${INSTALL_PREFIX}/src"
		git clone git://sourceware.org/git/binutils-gdb.git
	fi

	cd "${INSTALL_PREFIX}/src/binutils-gdb"
	git checkout "${TAG}"
	git pull

	CC=gcc ./configure \
		--with-python=/usr/bin/python3 \
		--prefix=/usr/local \
		&& make  \
		&& sudo make install

	local ret=$?
	if [[ "${ret}" == 0 ]]; then
		local -r priority="$(expr $(getPriority gdb) + 1)"

		sudo update-alternatives --install /usr/bin/gdb gdb "${INSTALL_PREFIX}/bin/gdb" "${priority}"

	fi
}

# install_gdb gdb-7.12.1-release
install_gdb gdb-14.1-release

# vim: ts=3 sw=3 sts=0 noet :
