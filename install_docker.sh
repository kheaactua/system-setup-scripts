#!/bin/bash

function install_docker_service()
{
  # Run's the installation recommended by
  # https://docs.docker.com/engine/install/ubuntu/ rather than the default
  # apt-get

  apt-get update \
    && apt-get install -qy \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common \

	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
	apt-key fingerprint 0EBFCD88

	# https://askubuntu.com/a/989941/163365
	apt-get --allow-releaseinfo-change update

	add-apt-repository \
     "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
$(lsb_release -cs) \
stable"

	apt-get update \
  && apt-get install -qy docker-ce docker-ce-cli containerd.io
}

install_docker_service

# vim: ts=2 sw=2 sts=0 expandtab :
