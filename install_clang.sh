#!/bin/zsh

zmodload zsh/pcre

declare -r VERSION=9.0.0

# Source list for apt
declare -r list_file="/etc/apt/sources.list.d/llvm.list"

if [[ ! -f "${list_file}" ]]; then
	# Create the file
	touch "${list_file}";
fi;

function getPriority() {
	# Which alternative target name to query
	local -r bin=$1

	query=$(update-alternatives --display $bin     | \
		  grep priority                             | \
		  cut -d' ' -f 4                            | \
		  sort                                      | \
		  tail -n 1                                   \
	)
	echo $query
}

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

# TODO: Why didn't I use a regex here?
function getIssue() {
	local -r issue="$(cat /etc/issue)"
	if [[ "${issue}" =~ 14.04* ]]; then
		echo "14.04"
	elif [[ "${issue}" =~ 16.04* ]]; then
		echo "16.04"
	elif [[ "${issue}" =~ 18.04* ]]; then
		echo "18.04"
	elif [[ "${issue}" =~ 19.04* ]]; then
		echo "19.04"
	elif [[ "${issue}" =~ 19.10* ]]; then
		echo "19.10"
	else
		echo "Unknown issue!" >&2
		exit 1
	fi
}

function install_with_llvm_script()
{
	local -r v=$(echo "$1" | sed 's/\([[:digit:]]\).*/\1/')
	local -r install_bin_path=/usr/bin
	local -r priority=$(expr $(getPriority clang++) + 1)

	tmp=$(mktemp -d)
	wget -O ${tmp}/llvm.sh https://apt.llvm.org/llvm.sh \
		&& chmod +x ${tmp}/llvm.sh \
		&& ${tmp}/llvm.sh ${v} \
		&&	update-alternatives \
			--install /usr/bin/clang           clang           ${install_bin_path}/clang-${v}           ${priority} \
			--slave   /usr/bin/clang++         clang++         ${install_bin_path}/clang++-${v}                     \
			--slave   /usr/bin/llvm-symbolizer llvm-symbolizer ${install_bin_path}/llvm-symbolizer-${v}             \
			--slave   /usr/bin/lldb-server     lldb-server     ${install_bin_path}/lldb-server-${v}                 \
			--slave   /usr/bin/clang-tidy      clang-tidy      ${install_bin_path}/clang-tidy-${v}                  \
			--slave   /usr/bin/clang-format    clang-format    ${install_bin_path}/clang-format-${v}                \
			--slave   /usr/bin/llvm-config     llvm-config     ${install_bin_path}/llvm-config-${v}
}

function install_version_apt()
{
	local -r v=$1;

	# Is this v already in the file?
	grep -q "${v}" "${list_file}" 2>&1 > /dev/null;
	ret=$?

	if [[ "${ret}" != 0 ]]; then
		if [ "0" == "$(id -u)" ]; then
			wget -O - http://llvm.org/apt/llvm-snapshot.gpg.key|apt-key add -
			echo "deb     http://llvm.org/apt/$(getIssueName)/ llvm-toolchain-$(getIssueName)-${v} main" >> "${list_file}"
			echo "deb-src http://llvm.org/apt/$(getIssueName)/ llvm-toolchain-$(getIssueName)-${v} main" >> "${list_file}"
		else
			echo "Cannot add required key to apt sources"
		fi
	fi

		# install the required build dependencies:
		local -r priority=$(expr $(getPriority clang++) + 1)

		local -r install_path=/usr/bin

		apt-get update \
			&& apt-get install -y clang-${v} clang-tidy-${v} libclang-${v}-dev libclang-common-${v}-dev libclang1-${v} libllvm${v} lldb-${v} clang-format-${v} libncurses5-dev libssl-dev \
			&&	update-alternatives \
				--install /usr/bin/clang           clang           ${install_bin_path}/clang-${v}           ${priority} \
				--slave   /usr/bin/clang++         clang++         ${install_bin_path}/clang++-${v}                     \
				--slave   /usr/bin/llvm-symbolizer llvm-symbolizer ${install_bin_path}/llvm-symbolizer-${v}             \
				--slave   /usr/bin/lldb-server     lldb-server     ${install_bin_path}/lldb-server-${v}                 \
				--slave   /usr/bin/clang-tidy      clang-tidy      ${install_bin_path}/clang-tidy-${v}                  \
				--slave   /usr/bin/clang-format    clang-format    ${install_bin_path}/clang-format-${v}                \
				--slave   /usr/bin/llvm-config     llvm-config     ${install_bin_path}/llvm-config
}

function install_version_bin() {
	set -e
	local -r v=$1;
	local -r major_v=$(echo "$v" | sed 's/\([[:digit:]]\).*/\1/')
	local -r tmp_dest=/tmp
	local -r dest_base=/usr/local

	if [[ $v =~ 5.0.0 ]]; then
		local -r fname=clang+llvm-${v}-linux-x86_64-ubuntu$(getIssue).tar.xz
	else
		local -r fname=clang+llvm-${v}-x86_64-linux-gnu-ubuntu-$(getIssue).tar.xz
	fi
	local dest=${dest_base}/${fname/.tar.xz/}

	if [[ ! -e "${tmp_dest}/${fname}" || ! -s "${tmp_dest}/${fname}" ]]; then
		wget -O "${tmp_dest}/${fname}" "http://releases.llvm.org/${v}/${fname}"
		if [[ ! -s "${tmp_dest}/${fname}" ]]; then
			echo "Could not download ${fname}"
			exit -1
		fi
	fi

	if [[ ! -e "${dest}" ]]; then
		tar -xavf ${tmp_dest}/${fname} --no-same-permissions -C ${dest_base}/ && ( echo "Could not untar ${fname}" || exit -1 )
	fi

	# Install alternatives (we need clang to be in a standard place)

		# if we're root
		if [[ "0" == "$(id -u)" ]]; then

			# Fix up the permissions
			chown -R root:root "${dest}"
			chmod -R g+r,o+r "${dest}"
			find ${dest} -type d -exec chmod g+x,o+x {} \;

			# install the required build dependencies:
			local -r priority=$(expr $(getPriority clang) + 1)

			local -r install_path=/usr/local/${fname/.tar.xz/}
			local -r install_bin_path=${install_path}/bin
			local -r install_lib_path=${install_path}/lib
			local -r install_share_path=${install_path}/share

			update-alternatives                                                                                   \
				--install /usr/bin/clang           clang           ${install_bin_path}/clang           ${priority} \
				--slave   /usr/bin/clang++         clang++         ${install_bin_path}/clang++                     \
				--slave   /usr/bin/llvm-symbolizer llvm-symbolizer ${install_bin_path}/llvm-symbolizer             \
				--slave   /usr/bin/clang-tidy      clang-tidy      ${install_bin_path}/clang-tidy                  \
				--slave   /usr/bin/clang-format    clang-format    ${install_bin_path}/clang-format                \
				--slave   /usr/bin/llvm-config     llvm-config     ${install_bin_path}/llvm-config                 \
				--slave   /usr/share/clang/clang-format.py clang-format.py ${install_share_path}/clang/clang-format.py \
			&& update-alternatives                                                                                \
				--install /usr/bin/ld              ld              ${install_bin_path}/ld.lld          ${priority} \

			# Depending on what we chose to download, this mightn't exist.
			if [[ -e ${install_bin_path}/lldb-server ]]; then
			update-alternatives                                                                                   \
				--install /usr/bin/clang           clang           ${install_bin_path}/clang           ${priority} \
				--slave   /usr/bin/lldb-server     lldb-server     ${install_bin_path}/lldb-server
			fi

			# I don't know if this is a terrible idea, but, it'll probably work....
			local clanglibs;
			clanglibs=($(find ${install_lib_path} -iname 'libclang.so*'))
			for l in ${clanglibs}; do
				local libname=$(basename $l)
				update-alternatives --install /usr/lib/x86_64-linux-gnu/${libname} ${libname} ${install_lib_path}/${libname} ${priority}
			done

			# clanglibs=($(find ${install_lib_path} -iname 'libclangBasic.a*' -or ))
			# for l in ${clanglibs}; do
			# 	ln -s ${install_lib_path}/libclangBasic.a /usr/lib/llvm-${major_v}/lib/libclangBasic.a
			# done

		else
			echo "Not setting alternatives (requires root permission)"
		fi

	# Install module file (so we can load everything we need for clang)

		if [[ "0" == "$(id -u)" ]]; then
			dest=/usr/share/modules/modulefiles
		else
			dest="${HOME}/.modulefiles"
		fi
		if [[ ! -e "${dest}" ]]; then
			mkdir -p "${dest}"
		fi

		echo "Installing module files to ${dest}"
		cp -r modules/clang "${dest}"
}

function install_version() {
	local -r v=$1;

	# [[ "${v}" -pcre-match "^(\d+\.\d+).*" ]] && install_version_apt $match[1] || echo "Could not read version"
	install_version_bin $1
	# install_with_llvm_script $1
}


install_version "${VERSION}"

# vim: ts=3 sw=3 sts=0 noet :
