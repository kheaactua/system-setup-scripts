#!/bin/zsh

declare -r VERSION=4.0

# Source list for apt
declare -r list_file="/etc/apt/sources.list.d/llvm.list"

if [[ ! -f "${list_file}" ]]; then
	# Create the file
	touch "${list_file}";
fi;

function getPriority() {
	# Which alternative target name to query
	local -r bin=$1

	query=$(update-alternatives --display $bin | \
	           grep priority |                   \
				  cut -d' ' -f 4 |                  \
				  sort |                            \
				  tail -n 1                         \
	       )
	echo $query
}

function getIssueName() {
	local -r issue="$(cat /etc/issue)"
	if [[ "${issue}" =~ 14.04* ]]; then
		echo "trusty"
	elif [[ "${issue}" =~ 16.04* ]]; then
		echo "xenial"
	else
		echo "Unknown issue!" >&2
		exit 1
	fi
}

function install_version() {
	local -r v=$1;

	# Is this v already in the file?
	grep -q "${v}" "${list_file}" 2>&1 > /dev/null;
	ret=$?

	if [[ "${ret}" != 0 ]]; then
		wget -O - http://llvm.org/apt/llvm-snapshot.gpg.key|apt-key add -
		echo "deb     http://llvm.org/apt/$(getIssueName)/ llvm-toolchain-$(getIssueName)-${v} main" >> "${list_file}"
		echo "deb-src http://llvm.org/apt/$(getIssueName)/ llvm-toolchain-$(getIssueName)-${v} main" >> "${list_file}"
	fi

	# install the required build dependencies:
	local -r priority=$(expr $(getPriority clang++) + 1)

	apt-get update \
		&& apt-get install -y clang-${v} clang-tidy-${v} libclang-${v}-dev libclang-common-${v}-dev libclang1-${v} libllvm${v} lldb-${v} clang-format-${v} libncurses5-dev libssl-dev \
		&& update-alternatives --install /usr/bin/clang++         clang++         /usr/bin/clang++-${v}         ${priority}  \
		&& update-alternatives --install /usr/bin/clang           clang           /usr/bin/clang++-${v}         ${priority}  \
		&& update-alternatives --install /usr/bin/llvm-symbolizer llvm-symbolizer /usr/bin/llvm-symbolizer-${v} ${priority}  \
		&& update-alternatives --install /usr/bin/lldb-server     lldb-server     /usr/bin/lldb-server-${v}     ${priority}  \
		&& update-alternatives --install /usr/bin/clang-tidy      clang-tidy      /usr/bin/clang-tidy-${v}      ${priority}  \
		&& update-alternatives --install /usr/bin/clang-format    clang-format    /usr/bin/clang-format-${v}    ${priority}  \

}

install_version "${VERSION}"

# vim: ts=3 sw=3 sts=0 noet :
