#!/bin/bash

# This script downloads, builds, and installs lua

declare -r GO_VERSION=5.4.3
declare -r INSTALL_PREFIX=/usr/local

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

function install_go() {
	local -r v=${1:-${GO_VERSION}}
	local -r priority=$(expr $(getPriority go) + 1)

	# Get the source
	cd "${src}"
	curl -R -O https://go.dev/dl/go${v}.linux-amd64.tar.gz
	tar -C /usr/local/go/${v} -xzf go${v}.linux-amd64.tar.gz

	update-alternatives --install /usr/bin/go go /usr/local/go/${v}/go/bin/go 70 \
		--slave /usr/bin/gofmt gofmt /usr/local/go/${v}/go/bin/gofmt
}

# have not tested..
install_go ${GO_VERSION}

# vim: ts=3 sw=3 sts=0 noet :
