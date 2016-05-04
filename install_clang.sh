#!/bin/zsh

declare -r VERSION=3.8

# Source list for apt
declare -r list_file="/etc/apt/sources.list.d/llvm.list"

if [[ ! -f "${list_file}" ]]; then
	# Create the file
	touch "${list_file}";
fi;

function install_version() {
	local -r v=$1;

	# Is this version already in the file?
	grep -q "${VERSION}" "${list_file}" 2>&1 > /dev/null;
	ret=$?

	if [[ "${ret}" != 0 ]]; then
		wget -O - http://llvm.org/apt/llvm-snapshot.gpg.key|apt-key add -
		echo "deb http://llvm.org/apt/trusty/ llvm-toolchain-trusty-${VERSION} main"     >> "${list_file}"
		echo "deb-src http://llvm.org/apt/trusty/ llvm-toolchain-trusty-${VERSION} main" >> "${list_file}"

		# install the required build dependencies:
		apt-get update
		apt-get install -y cmake ninja-build clang-${VERSION} libclang-${VERSION}-dev libclang-common-${VERSION}-dev libclang1-${VERSION} libllvm${VERSION} libncurses5-dev libssl-dev git g++

	fi
}

install_version "${VERSION}"

# vim: ts=3 sw=3 sts=0 noet :
