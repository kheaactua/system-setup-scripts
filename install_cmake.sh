#!/bin/bash

source getPriority.sh

function install_cmake() {

	local -r TAG=$1
	local -r INSTALL_PREFIX=${2:-/usr/local}

	# Get the source:
	if [[ ! -d "${INSTALL_PREFIX}/src/CMake" ]]; then
		mkdir -p "${INSTALL_PREFIX}/src"
		cd "${INSTALL_PREFIX}/src"
		git clone https://github.com/Kitware/CMake
	fi

	cd "${INSTALL_PREFIX}/src/CMake"
	git fetch
	git checkout ${TAG}
	git pull

	local flags=""
	flags="--parallel=4"

	# Is ccache available?
	ccache_path=$(which ccache 2>/dev/null)
	if [[ $? == 0 ]]; then
		flags+=" --enable-ccache"
	fi


	./bootstrap ${flags}             \
		&& make                       \
		&& make install

	local ret=$?
	if [[ "${ret}" == 0 ]]; then
		local -r priority=$(expr $(getPriority cmake) + 1)

		update-alternatives --install /usr/bin/cmake cmake ${INSTALL_PREFIX}/bin/cmake ${priority}    \
		&& update-alternatives --install /usr/bin/ctest ctest ${INSTALL_PREFIX}/bin/ctest ${priority} \
		&& update-alternatives --install /usr/bin/cpack cpack ${INSTALL_PREFIX}/bin/cpack ${priority}

	else
		echo "CMake build failed"
	fi
}

install_cmake v3.9.1

# vim: ts=3 sw=3 sts=0 noet :
