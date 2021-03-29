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
	if [[ "" == "${query}" ]]; then
		query=60
	else
		query=$(($query+1))
	fi
	echo $query
}

function install_neovim_deps()
{
	apt-get update

	# The following dependencies are required for
	# python support in neovim:
	apt-get install -y python-dev python-pip python3-dev python3-pip

	# This dependency is require for using the system clipboard:
	which xsel > /dev/null || apt-get install -y xsel

	pip3 install neovim
}

function install_neovim_alternatives()
{
	local -r bin=$1
	local -r pri=$(getPriority vi)

	update-alternatives    --install /usr/bin/vi     vi     ${bin} ${pri} \
	&& update-alternatives --install /usr/bin/vim    vim    ${bin} ${pri} \
	&& update-alternatives --install /usr/bin/editor editor ${bin} ${pri}
}

function install_neovim()
{
	# See if neovim is already installed:
	if hash nvim 2>/dev/null; then
	  echo "Neovim already installed"
	 exit 0
	fi

	apt-get install -y neovim

	install_neovim_deps \
	&& install_neovim_alternatives /usr/bin/nvim
}

function install_neovim_latest()
{
	local -r TAG=$1

	set -x
	local -r INSTALL_PREFIX=/usr/local

	# Get the source:
	if [[ ! -d "${INSTALL_PREFIX}/src/neovim" ]]; then
		mkdir -p "${INSTALL_PREFIX}/src"
		cd "${INSTALL_PREFIX}/src"
		git clone https://github.com/neovim/neovim.git
	fi

	apt-get install -y \
		cmake           \
		libtool-bin     \


	cd "${INSTALL_PREFIX}/src/neovim"
	git reset --hard
	git fetch origin
	git checkout "${TAG}"
	git pull

	# TODO If behind a proxy, make sure http_proxy/https_proxy are set in the
	#      environment here (for now I've just been manally placing them here.)
	#      ALternatively I've been experimeting with a .netrc file that might
	#      help
	make CMAKE_BUILD_TYPE=Release  \
	&& make install                \
	&& install_neovim_deps         \
	&& install_neovim_alternatives /usr/local/src/neovim/build/bin/nvim
}

# install_neovim
install_neovim_latest 070e084

# vim: ts=3 sw=3 sts=0 noet :
