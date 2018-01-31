#!/bin/bash

source getPriority.sh

declare version=${1:-0.29.2}

if [[ "0" == "$(id -u)" ]]; then
	declare prefix=${2:-/usr/local}
else
	declare prefix=${2:-${HOME}}
fi

function install_pkgconfig() {

	local -r TAG=$1
	local -r INSTALL_PREFIX=${2:-/usr/local}

	# Get the source:
	if [[ ! -e "${INSTALL_PREFIX}/src/pkg-config" ]]; then
		mkdir -p "${INSTALL_PREFIX}/src"
		cd "${INSTALL_PREFIX}/src"
		wget -O source.tar.gz https://pkg-config.freedesktop.org/releases/pkg-config-${TAG}.tar.gz
		tar -xaf source.tar.gz
		mv pkg-config-${TAG} pkg-config
	fi

	cd "${INSTALL_PREFIX}/src/pkg-config"

	./configure --prefix=${INSTALL_PREFIX}  \
		&& make           \
		&& make install

	local ret=$?

	if [[ "${ret}" != 0 ]]; then
		echo "pkg-config build failed" >&2
		return;
	fi

	# if we're root
	if [[ "0" == "$(id -u)" ]]; then

		local -r priority=$(expr $(getPriority cmake) + 1)

		   update-alternatives --install /usr/bin/pkg-config pkg-config "${INSTALL_PREFIX}/bin/pkg-config" "${priority}"

	else
		echo "Not setting alternatives (requires root permission)"
	fi
}

# install_pkgconfig "${version}" "${prefix}"

# vim: ts=3 sw=3 sts=0 noet :
