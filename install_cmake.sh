#!/bin/bash

source getPriority.sh

function install_cmake() {

	local -r TAG=$1
	local -r INSTALL_PREFIX=${2:-/usr/local}

	# Get the source:
	if [[ ! -d "${INSTALL_PREFIX}/src/cmake" ]]; then
		mkdir -p "${INSTALL_PREFIX}/src"
		cd "${INSTALL_PREFIX}/src"
		git clone https://github.com/Kitware/CMake
	fi

	cd "${INSTALL_PREFIX}/src/CMake"
	git fetch
	git checkout ${TAG}
	git pull

	./bootstrap                      \
		&& make                       \
		&& make install

	local ret=$?
	if [[ "${ret}" == 0 ]]; then
		local -r priority=$(expr $(getPriority cmake) + 1)

		update-alternatives --install /usr/bin/cmake cmake ${INSTALL_PREFIX}/bin/cmake ${priority}

	else
		echo "CMake build failed"
	fi
}

install_cmake 3.9.0

# vim: ts=3 sw=3 sts=0 noet :
