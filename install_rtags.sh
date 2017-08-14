#!/bin/bash

# This script downloads, builds, and installs rtags

declare CMAKE_BIN=${CMAKE_BIN:-$(which cmake)}
if [[ ! -e "${CMAKE_BIN}" ]]; then
	echo "Cannot find cmake.  Please specify the cmake binary with the environment variable CMAKE_BIN"
	exit 192
fi

function pre_install() {
	# Ensure realpath is installed
	if [[ $(whoami) == "root" ]]; then
		apt-get install -y realpath libreadline-dev libc++-dev libc++abi-dev
	else
		echo "Make sure the following apt packages are installed: realpath libreadline-dev libc++-dev libc++abi-dev"
	fi

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

	# Is this even needed?  lua is an rtags submodule.
	./install_lua.sh
}

# Default this just incase
# Not sure why I do any of this... so I'm not even going to use it in the function below anymore.
declare -r CLANG_VERSION_auto=$(realpath /etc/alternatives/clang | sed 's/.*\([[:digit:]]\.[[:digit:]]\).*/\1/')
declare -r CLANG_VERSION=${CLANG_VERSION_auto:-4.0}
declare -r CLANG_BASE_DIR=$(dirname $(dirname $(realpath $(which clang++))))

declare -r INSTALL_PREFIX=/usr/local

function install_version() {
	local -r branch=${1:-master}

	# Get the source:
	local -r src="${INSTALL_PREFIX}/src"
	local -r bld="${src}/rtags/build-${branch}"
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
	git fetch
	git checkout ${branch}

	# Update source
	git pull origin ${branch}

	# Update submodules
	git submodule update --init --recursive

	# Create the build directory
	mkdir -p "${bld}"
	cd "${bld}"

	# 14.04 has a weird regex error in libstdc++ that prevents rdm from
	# building, so use libc with 14.04, on 16.04 though, this won't work, so use
	# libstdc++ http://stackoverflow.com/a/37097327/1861346
	local is_1404=0
	grep 14.04 /etc/issue > /dev/null && is_1404=1
	if [[ ${is_1404} == 1 ]]; then
		libc="libc++"
	else
		libc="libstdc++"
	fi

	# Build and install the source:
	CXX=clang++ CC=clang ${CMAKE_BIN}           \
		-DCMAKE_BUILD_TYPE=Release               \
		-DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} \
		-DLIBCLANG_LLVM_CONFIG_EXECUTABLE=llvm-config \
		-DCMAKE_C_COMPILER=clang                 \
		-DCMAKE_CXX_FLAGS="-std=c++11 -stdlib=${libc}" \
		..                                       \
	&& make install

}

pre_install
install_version v2.10

# vim: ts=3 sw=3 sts=0 noet ffs=unix :
