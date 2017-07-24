#!/bin/bash

function getPriority() {
	# TODO put this in a lib to include

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

function install_vlc() {

	local -r TAG=$1
	local -r INSTALL_PREFIX=${2:-/usr/local}

	# Build dependencies
	apt-get install -y libvorbis libvorbis-dev libmad0-dev libavutil-dev libavcodec-dev libavformat-dev libswscale-dev liba52-0.7.4-dev libxcb-shm0-dev libxcb-composite0-dev libxcb-xv0-dev libxcb-xvmc0-dev libasound2-dev libgcrypt20-dev liblua5.2-dev


	# Get the source:
	if [[ ! -d "${INSTALL_PREFIX}/src/vlc" ]]; then
		mkdir -p "${INSTALL_PREFIX}/src"
		cd "${INSTALL_PREFIX}/src"
		git clone https://github.com/videolan/vlc
	fi

	cd "${INSTALL_PREFIX}/src/vlc"
	git checkout ${TAG}
	git pull

	# Alternatively: --with-kde-solid=${INSTALL_PREFIX}/share/apps/solid (instead of without-kde-solid)

	./bootstrap                      \
		&& ./configure                \
			--prefix=${INSTALL_PREFIX} \
			--without-kde-solid        \
		&& make                       \
		&& make install

	local ret=$?
	if [[ "${ret}" == 0 ]]; then
		local -r priority=$(expr $(getPriority vlc) + 1)

		update-alternatives --install /usr/bin/vlc vlc ${INSTALL_PREFIX}/bin/vlc ${priority}

	else
		echo "Build failed, did you apply to Lua fix described at https://mailman.videolan.org/pipermail/vlc-devel/2015-February/101262.html ?"
	fi
}

install_vlc 2.2.0-git

# vim: ts=3 sw=3 sts=0 noet :
