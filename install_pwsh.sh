#!/bin/bash

# https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-linux?view=powershell-7

# TODO: Why didn't I use a regex here?
# TODO why isn't this in a lib?
function getIssue() {
	local -r issue="$(cat /etc/issue)"
	if [[ "${issue}" =~ 14.04* ]]; then
		echo "14.04"
	elif [[ "${issue}" =~ 16.04* ]]; then
		echo "16.04"
	elif [[ "${issue}" =~ 18.04* ]]; then
		echo "18.04"
	else
		echo "Unknown issue!" >&2
echo "If this is 19.04+, then use snapd or someting"
		exit 1
	fi
}

function install_pwsh() {
    set -e
    tmp=$(mktemp -d)

    # Download the Microsoft repository GPG keys
    wget -q -O $tmp/packages-microsoft-prod.deb https://packages.microsoft.com/config/ubuntu/$(getIssue)/packages-microsoft-prod.deb

    # Register the Microsoft repository GPG keys
    dpkg -i $tmp/packages-microsoft-prod.deb

    # Update the list of products
    apt-get update

    # Enable the "universe" repositories
    add-apt-repository universe

    # Install PowerShell
    apt-get install -y powershell
}

 install_pwsh

# vim: ts=3 sw=3 sts=0 noet :
