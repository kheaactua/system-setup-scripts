#!/bin/bash

source getPriority.sh

declare -r version=${1:-v3.16.4}

if [ "0" == "$(id -u)" ]; then
	declare -r prefix=${2:-/usr/local}
else
	declare -r prefix=${2:-${HOME}}
fi

function getIssueName() {
	local -r issue="$(cat /etc/issue)"
	if [[ "${issue}" =~ 14.04* ]]; then
		echo "trusty"
	elif [[ "${issue}" =~ 16.04* ]]; then
		echo "xenial"
	elif [[ "${issue}" =~ 18.04* ]]; then
		echo "bionic"
	elif [[ "${issue}" =~ 19.04* ]]; then
		echo "disco"
	elif [[ "${issue}" =~ 19.10* ]]; then
		echo "eoan"
	else
		echo "Unknown issue!" >&2
		exit 1
	fi
}

function install_cmake_from_src()
{
	local -r TAG=$1
	local -r INSTALL_PREFIX=${2:-/usr/local}

	local pkgs=(libncurses5-dev libssl-dev)
	for p in $pkgs; do
		local check_exists=$(dpkg -s $p)
		if [[ $? != 0 ]]; then
			if [ "0" == "$(id -u)" ]; then
				apt-get install -f $p
			else
				echo "Missing $p" >&2
				exit 1
			fi
		fi
	done

	# Get the source:
	if [[ ! -e "${INSTALL_PREFIX}/src/CMake" ]]; then
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
	flags=" --prefix=${INSTALL_PREFIX}"

	# Is ccache available?
	ccache_path=$(which ccache 2>/dev/null)
	if [[ $? == 0 ]]; then
		flags+=" --enable-ccache"
	fi

	./bootstrap ${flags}             \
		&& make -j 3                  \
		&& make install

	local ret=$?

	if [[ "${ret}" != 0 ]]; then
		echo "CMake build failed" >&2
		exit 1;
	fi

	# if we're root
	if [ "0" == "$(id -u)" ]; then

		local -r priority=$(expr $(getPriority cmake) + 1)

		   update-alternatives --install /usr/bin/cmake  cmake  ${INSTALL_PREFIX}/bin/cmake  ${priority} \
		&& update-alternatives --install /usr/bin/ctest  ctest  ${INSTALL_PREFIX}/bin/ctest  ${priority} \
		&& update-alternatives --install /usr/bin/cpack  cpack  ${INSTALL_PREFIX}/bin/cpack  ${priority} \
		&& update-alternatives --install /usr/bin/ccmake ccmake ${INSTALL_PREFIX}/bin/ccmake ${priority}

	else
		echo "Not setting alternatives (requires root permission)"
	fi
}

function install_cmake_from_ppa() {
	# https://apt.kitware.com/
	apt-get update && sudo apt-get install apt-transport-https ca-certificates gnupg software-properties-common wget

	wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | sudo apt-key add -

	apt-add-repository "deb https://apt.kitware.com/ubuntu/ $(getIssueName) main"
	apt-get update

	apt-get install kitware-archive-keyring
	apt-key --keyring /etc/apt/trusted.gpg del C1F34CDD40CD72DA

	apt install cmake -y
}

function install_cmake()
{
	local -r TAG=$1
	local -r INSTALL_PREFIX=${2:-/usr/local}

	install_cmake_from_ppa
}

install_cmake "${version}" "${prefix}"

# vim: ts=3 sw=3 sts=0 noet :
