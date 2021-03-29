#!/bin/bash

function install_nvidia_docker()
{
  # Instructions from https://github.com/NVIDIA/nvidia-docker

  # Add the package repositories
  distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
  curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | apt-key add -
  curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | tee /etc/apt/sources.list.d/nvidia-docker.list

  apt-get update && apt-get install -qy nvidia-container-toolkit
  systemctl restart docker
}

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

  # Credential Helper, my config files use it
  apt-get install -qy golang-docker-credential-helpers

  install_nvidia_docker
}

install_docker_service

# vim: ts=2 sw=2 sts=0 expandtab :
