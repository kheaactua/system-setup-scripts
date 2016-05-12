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

	# Is this v already in the file?
	grep -q "${v}" "${list_file}" 2>&1 > /dev/null;
	ret=$?

	if [[ "${ret}" != 0 ]]; then
		wget -O - http://llvm.org/apt/llvm-snapshot.gpg.key|apt-key add -
		echo "deb http://llangm.org/apt/trusty/ llvm-toolchain-trusty-${v} main"   >> "${list_file}"
		echo "deb-src http://llvm.org/apt/trusty/ llvm-toolchain-trusty-${v} main" >> "${list_file}"
	fi

	# install the required build dependencies:
	apt-get update  \
		&& apt-get install -y clang-${v} libclang-${v}-dev libclang-common-${v}-dev libclang1-${v} libllvm${v} libncurses5-dev libssl-dev \
		&& update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-${v} 100
		&& update-alternatives --install /usr/bin/llvm-symbolizer llvm-symbolizer /usr/bin/llvm-symbolizer-3.8 100
		&& update-alternatives --install /usr/bin/lldb-server lldb-server /usr/bin/lldb-server-3.8 100
}

install_version "${VERSION}"

# vim: ts=3 sw=3 sts=0 noet :
