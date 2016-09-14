#!/bin/bash

# This script downloads, builds, and installs rtags

function pre_install() {
	# Ensure realpath is installed
	apt-get install -y realpath libreadline-dev libc++-dev libc++abi-dev

	# Do we have clang?
	which clang 2>&1 >/dev/null
	if [[ $? != 0 ]]; then
		./install_clang.sh
		if [[ $? != 0 ]]; then
			echo "Could not install clang, existing." 2>&1 /dev/null
			exit -1;
		fi
	else
		echo "Clang is installed"
	fi

	./install_lua.sh
}

declare -r CLANG_VERSION_auto=$(realpath /etc/alternatives/clang | sed 's/.*\([[:digit:]]\.[[:digit:]]\).*/\1/')

# Default this just incase
declare -r CLANG_VERSION=${CLANG_VERSION_auto:-3.8}

declare -r INSTALL_PREFIX=/usr/local

function install_version() {
	local -r branch=${1:-master}

	# Get the source:
	local -r src="${INSTALL_PREFIX}/src"
	local -r bld="${src}/rtags/build"
	if [[ ! -d "${src}/rtags" ]]; then
		mkdir -p "${src}/rtags"
		cd "${src}"
		git clone https://github.com/Andersbakken/rtags.git

		# Init git submodules
		cd rtags
		git submodule init

	fi
	cd "${src}/rtags"

	# Checkout the proper branch/tag
	git checkout ${branch}

	# Update submodules
	git submodule update

	# Update source
	git pull origin ${branch}

	# Create the build directory
	mkdir -p "${bld}"
	cd "${bld}"

	# Build and install the source:
	CXX=clang++-${CLANG_VERSION} cmake          \
		-GNinja                                  \
		-DCMAKE_BUILD_TYPE=Release               \
		-DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} \
		-DLIBCLANG_LLVM_CONFIG_EXECUTABLE=/usr/bin/llvm-config-${CLANG_VERSION} \
		-DCMAKE_CXX_FLAGS="-std=c++11 -stdlib=libc++" \
		..                                       \
	&& ninja install

}

pre_install
install_version master

# vim: ts=3 sw=3 sts=0 noet ffs=unix :
