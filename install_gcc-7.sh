#!/bin/bash

function getPriority() {
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

function getDefaultGccVersion() {
	echo $(g++ --version | head -n 1 | sed -r 's/^.* ([[:digit:]])\..*$/\1/')
}

function install_gcc() {
	local -r v=$(getDefaultGccVersion)

	if [[ "${v}" == 7 ]]; then
		echo "Error: Default g++ is already version 7"
		return
	fi

	# Build dependencies
	apt-get install -y software-properties-common python-software-properties

	add-apt-repository ppa:ubuntu-toolchain-r/test
	apt update
	apt install g++-7 -y \
	\
	&& update-alternatives \
		--install /usr/bin/gcc gcc /usr/bin/gcc-7 $(expr $(getPriority gcc) + 1) \
		--slave /usr/bin/g++        g++        /usr/bin/g++-7 \
		--slave /usr/bin/gcc-ar     gcc-ar     /usr/bin/gcc-ar-7 \
		--slave /usr/bin/gcc-nm     gcc-nm     /usr/bin/gcc-nm-7 \
		--slave /usr/bin/gcc-ranlib gcc-ranlib /usr/bin/gcc-ranlib-7 \
	\
	&& update-alternatives \
		--install /usr/bin/gcc gcc /usr/bin/gcc-${v} $(expr $(getPriority gcc) + 11) \
		--slave /usr/bin/g++        g++ /usr/bin/g++-${v} \
		--slave /usr/bin/gcc-ar     gcc-ar /usr/bin/gcc-ar-${v} \
		--slave /usr/bin/gcc-nm     gcc-nm /usr/bin/gcc-nm-${v} \
		--slave /usr/bin/gcc-ranlib gcc-ranlib /usr/bin/gcc-ranlib-${v}
}

install_gcc

# vim: ts=3 sw=3 sts=0 noet :
