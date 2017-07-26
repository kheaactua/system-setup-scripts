#!/bin/zsh

zmodload zsh/pcre

declare -r VERSION=4.0.0

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

function getIssue() {
	local -r issue="$(cat /etc/issue)"
	if [[ "${issue}" =~ 14.04* ]]; then
		echo "14.04"
	elif [[ "${issue}" =~ 16.04* ]]; then
		echo "16.04"
	else
		echo "Unknown issue!" >&2
		exit 1
	fi
}

function install_version() {
	local -r v=$1;

	# [[ "${v}" -pcre-match "^(\d+\.\d+).*" ]] && install_version_apt $match[1] || echo "Could not read version"
	install_version_bin $1
}

function install_version_apt() {
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

	local -r install_path=/usr/bin

	apt-get update \
		&& apt-get install -y clang-${v} clang-tidy-${v} libclang-${v}-dev libclang-common-${v}-dev libclang1-${v} libllvm${v} lldb-${v} clang-format-${v} libncurses5-dev libssl-dev \
	   &&	update-alternatives --install /usr/bin/clang++         clang++         ${install_path}/clang++-${v}         ${priority}  \
		&& update-alternatives --install /usr/bin/clang           clang           ${install_path}/clang++-${v}         ${priority}  \
		&& update-alternatives --install /usr/bin/llvm-symbolizer llvm-symbolizer ${install_path}/llvm-symbolizer-${v} ${priority}  \
		&& update-alternatives --install /usr/bin/lldb-server     lldb-server     ${install_path}/lldb-server-${v}     ${priority}  \
		&& update-alternatives --install /usr/bin/clang-tidy      clang-tidy      ${install_path}/clang-tidy-${v}      ${priority}  \
		&& update-alternatives --install /usr/bin/clang-format    clang-format    ${install_path}/clang-format-${v}    ${priority}  \
		&& update-alternatives --install /usr/bin/llvm-config     llvm-config     ${install_path}/llvm-config          ${priority}  \

}

function install_version_bin() {
	local -r v=$1;
	local -r tmp_dest=/tmp
	local -r dest=/usr/local

	local fname=clang+llvm-${v}-x86_64-linux-gnu-ubuntu-$(getIssue).tar.xz

	if [[ ! -e ${tmp_dest}/${fname} ]]; then
		wget -O ${tmp_dest}/${fname} http://releases.llvm.org/${v}/${fname}
	fi

	tar -xavf ${tmp_dest}/${fname} -C ${dest}/

	# install the required build dependencies:
	local -r priority=$(expr $(getPriority clang++) + 1)

	local -r install_path=/usr/local/${fname/.tar.xz/}/bin

	update-alternatives       --install /usr/bin/clang++         clang++         ${install_path}/clang++         ${priority}  \
		&& update-alternatives --install /usr/bin/clang           clang           ${install_path}/clang           ${priority}  \
		&& update-alternatives --install /usr/bin/llvm-symbolizer llvm-symbolizer ${install_path}/llvm-symbolizer ${priority}  \
		&& update-alternatives --install /usr/bin/clang-tidy      clang-tidy      ${install_path}/clang-tidy      ${priority}  \
		&& update-alternatives --install /usr/bin/clang-format    clang-format    ${install_path}/clang-format    ${priority}  \
		&& update-alternatives --install /usr/bin/llvm-config     llvm-config     ${install_path}/llvm-config     ${priority}  \


	# Depending on what we chose to download, this mightn't exist.
	if [[ -e ${install_path}/lldb-server ]]; then
		update-alternatives --install /usr/bin/lldb-server     lldb-server     ${install_path}/lldb-server     ${priority}
	fi

}

install_version "${VERSION}"

# vim: ts=3 sw=3 sts=0 noet :
