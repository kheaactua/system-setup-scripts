#!/bin/bash

source $(dirname $0)/getPriority.sh

declare -r version=${1:-v3.20.2}

if [ "0" == "$(id -u)" ]; then
	declare -r prefix=${2:-/usr/local}
else
	declare -r prefix=${2:-${HOME}}
fi

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

	update_cmake_alternatives "${TAG}" "${INSTALL_PREFIX}"
}

function install_cmake_from_ppa() {
	# https://apt.kitware.com/
	apt-get update && sudo apt-get install apt-transport-https ca-certificates gnupg software-properties-common wget -yq

	wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | sudo apt-key add -

	apt-add-repository "deb https://apt.kitware.com/ubuntu/ $(lsb_release -rs) main"
	apt-get update

	apt-get install kitware-archive-keyring
	apt-key --keyring /etc/apt/trusted.gpg del C1F34CDD40CD72DA

	apt install cmake -qy
}

function install_cmake_binary() {
	local -r TAG=$1
	local -r INSTALL_PREFIX=${2:-/usr/local}

	local tmp=$(mktemp -d)
	wget -O ${tmp}/cmake_install.sh https://github.com/Kitware/CMake/releases/download/${TAG}/cmake-${TAG##v}-Linux-x86_64.sh \
	  && chmod u+x ${tmp}/cmake_install.sh \
	  && ${tmp}/cmake_install.sh --prefix=/usr/local --skip-license \
	  && rm ${tmp}/cmake_install.sh

	update_cmake_alternatives "${TAG}" "${INSTALL_PREFIX}"
}

function update_cmake_alternatives() {
	local -r TAG=$1
	local -r INSTALL_PREFIX=${2:-/usr/local}

	# if we're root
	if [ "0" == "$(id -u)" ]; then

		local -r priority=$(expr $(getPriority cmake) + 1)

		   # update-alternatives \
				# --install /bin/cmake  cmake  ${INSTALL_PREFIX}/bin/cmake  ${priority} \
				# --slave   /bin/ctest  ctest  ${INSTALL_PREFIX}/bin/ctest  \
				# --slave   /bin/cpack  cpack  ${INSTALL_PREFIX}/bin/cpack  \
				# --slave   /bin/ccmake ccmake ${INSTALL_PREFIX}/bin/ccmake

		   update-alternatives --force --install /bin/cmake  cmake  ${INSTALL_PREFIX}/bin/cmake  ${priority} \
		&& update-alternatives --force --install /bin/ctest  ctest  ${INSTALL_PREFIX}/bin/ctest  ${priority} \
		&& update-alternatives --force --install /bin/cpack  cpack  ${INSTALL_PREFIX}/bin/cpack  ${priority} \
		&& update-alternatives --force --install /bin/ccmake ccmake ${INSTALL_PREFIX}/bin/ccmake ${priority}

		echo "Updated alternatives: $(which cmake)"

	else
		echo "Not setting alternatives (requires root permission)"
	fi
}

function install_cmake()
{
	local -r TAG=$1
	local -r INSTALL_PREFIX=${2:-/usr/local}

	# install_cmake_from_ppa
	# install_cmake_from_src "${TAG}" "${INSTALL_PREFIX}"
	install_cmake_binary "${TAG}" "${INSTALL_PREFIX}"
}

install_cmake "${version}" "${prefix}"

# vim: ts=3 sw=3 sts=0 noet :
