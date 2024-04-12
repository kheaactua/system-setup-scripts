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
	set -e

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

	local src_base_dir=${INSTALL_PREFIX}/src
	local src_dir=${src_base_dir}/gdb

	if [[ ! -d "${src_base_dir}" ]]; then
		sudo mkdir -p "${scr_base_dir}"
	fi
	sudo chown -R $(whoami):$(whoami) "${src_base_dir}"

	# Get the source:
	if [[ ! -d "${src_dir}" ]]; then
		cd "${src_base_dir}"
		git clone git://sourceware.org/git/binutils-gdb.git -b "${TAG}" "${src_dir}"
	fi

	cd "${src_dir}"
	git fetch
	git checkout "${TAG}"

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
install_gdb gdb-14.2-release

# vim: ts=3 sw=3 sts=0 noet :
