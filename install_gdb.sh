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

	which bison 2>&1 > /dev/null
	if [[ $? != 0 ]]; then
		apt-get install bison
	fi

	which flex 2>&1 > /dev/null
	if [[ $? != 0 ]]; then
		apt-get install flex
	fi

	# Get the source:
	if [[ ! -d "${INSTALL_PREFIX}/src/gdb" ]]; then
		mkdir -p "${INSTALL_PREFIX}/src"
		cd "${INSTALL_PREFIX}/src"
		git clone git://sourceware.org/git/binutils-gdb.git
	fi

	cd "${INSTALL_PREFIX}/src/binutils-gdb"
	git checkout ${TAG}
	git pull

	CC=gcc ./configure --prefix=/usr/local \
		&& make                             \
		&& make install

	local ret=$?
	if [[ "${ret}" == 0 ]]; then
		local -r priority=$(expr $(getPriority gdb) + 1)

		update-alternatives --install /usr/bin/gdb gdb ${INSTALL_PREFIX}/bin/gdb ${priority}

	fi
}

install_gdb gdb-7.12.1-release

# vim: ts=3 sw=3 sts=0 noet :
