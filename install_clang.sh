#!/bin/zsh

zmodload zsh/pcre


function getPriority() {
	# Which alternative target name to query
	local -r bin=$1

	query=$(update-alternatives --display "${bin}" \
		  | grep priority  \
		  | cut -d' ' -f 4 \
		  | sort           \
		  | tail -n 1      \
	)
	echo "${query}"
}

function do-update-alternatives() {
	# Check if the command is available
	if ! command -v update-alternatives &> /dev/null; then
		echo "update-alternatives could not be found"
		return 1
	fi

	local -r v="${1}"
	local -r prefix="${2}"

	update-alternatives \
		--install /usr/bin/clang           clang           "${prefix}/clang-${v}"           "${priority}" \
		--slave   /usr/bin/clang++         clang++         "${prefix}/clang++-${v}"                       \
		--slave   /usr/bin/llvm-symbolizer llvm-symbolizer "${prefix}/llvm-symbolizer-${v}"               \
		--slave   /usr/bin/lldb            lldb            "${prefix}/lldb-${v}"                          \
		--slave   /usr/bin/lldb-server     lldb-server     "${prefix}/lldb-server-${v}"                   \
		--slave   /usr/bin/llvm-config     llvm-config     "${prefix}/llvm-config-${v}"                   \
		--slave   /usr/bin/clang-tidy      clang-tidy      "${prefix}/clang-tidy-${v}"                    \
		--slave   /usr/bin/clang-format    clang-format    "${prefix}/clang-format-${v}"                  \
		--slave   /usr/bin/clangd          clangd          "${prefix}/clangd-${v}"                        \
		--slave   /usr/bin/lld             lld             "${prefix}/lld-${v}"                           \
		--slave   /usr/bin/llvm-ar         llvm-ar         "${prefix}/llvm-ar-${v}"                       \
		--slave   /usr/bin/llvm-ranlib     llvm-ranlib     "${prefix}/llvm-ranlib-${v}"                   \
		--slave   /usr/bin/run-clang-tidy.py        run-clang-tidy.py        "${prefix}/run-clang-tidy-${v}.py"        \
		--slave   /usr/bin/run-clang-tidy           run-clang-tidy           "${prefix}/run-clang-tidy-${v}"           \
		--slave   /usr/bin/clang-apply-replacements clang-apply-replacements "${prefix}/clang-apply-replacements-${v}" \
		--slave   /usr/bin/clang-scan-deps   "clang-scan-deps-${v}" "${prefix}/clang-scan-deps-${v}"        \

	return $?
}

function download_llvm_install_script()
{
	local -r dest="${1:-/tmp}"
	wget -O "${dest}/llvm.sh" https://apt.llvm.org/llvm.sh \
		&& chmod +x "${dest}/llvm.sh"
	echo "${dest}/llvm.sh"

	if [[ -e "${dest}/llvm.sh" ]]; then
		return 0
	else
		return 1
	fi
}

function install_with_llvm_script()
{
	# llvm basically justs adds repos and apt installs clang, so it all goes to
	# /usr/bin
  local -r priority=$(("$(getPriority clang)" + 1))

  local -r install_bin_path=${1:-/usr/bin}

	local -r tmp="$(mktemp -d)"
	download_llvm_install_script "${tmp}" \
			|| { echo "Failed to download llvm install script"; return 1; }

  local -r v=$(source <(grep --color=never "^CURRENT_LLVM_STABLE=[[:digit:]]" "${tmp}/llvm.sh") && echo ${CURRENT_LLVM_STABLE})

  local -a pkgs=(
    "clang-format-${v}" "clang-tidy-${v}" \
    "libclang-${v}-dev" "lldb-${v}" \
    "lld-${v}" \
  )

  "${tmp}/llvm.sh" "${v}" \
  && apt-get install "${pkgs[@]}" -qy \
		&&	do-update-alternatives "${v}" "${install_bin_path}"
}


install_with_llvm_script "/usr/bin"

# vim: ts=3 sw=3 sts=0 noet :
