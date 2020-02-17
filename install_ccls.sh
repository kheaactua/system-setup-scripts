#!/bin/bash

function getPriority() {
	# TODO put this in a lib to include

	# Which alternative target name to query
	local -r bin=$1

	query=$(update-alternatives --display $bin | \
		grep priority                           | \
		cut -d' ' -f 4                          | \
		sort                                    | \
		tail -n 1                         \
	)
	echo $query
}

function getDefaultGccVersion() {
	echo $(g++ --version | head -n 1 | sed -r 's/^.* ([[:digit:]])\..*$/\1/')
}

function install_ccls() {
	local -r v=$(getDefaultGccVersion)
	if (( "${v}" < 7 )); then
		echo -e "Error: gcc7 is required, detected ${v}.  Use the install_gcc-7.sh script to install it and then choose it with\nupdate-alternatives --config gcc"
		return
	fi

	local -r INSTALL_PREFIX=/usr/local

	# Get the source:
	if [[ ! -d "${INSTALL_PREFIX}/src/ccls" ]]; then
		mkdir -p "${INSTALL_PREFIX}/src"
		cd "${INSTALL_PREFIX}/src" \
		&& git clone --depth=1 --recursive https://github.com/MaskRay/ccls
	fi

	cd "${INSTALL_PREFIX}/src/ccls"
	git reset --hard
	git pull

	cmake                                    \
		-DCMAKE_BUILD_TYPE=Release            \
		-DCMAKE_INSTALL_PREFIX=/usr/local     \
	&& cmake --build .                       \
	&& cmake --build . --target install      \
	&& echo "ccls succesfully installed"
}

install_ccls

# vim: ts=3 sw=3 sts=0 noet :
