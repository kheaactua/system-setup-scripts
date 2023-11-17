#!/bin/bash

function install_docker_service()
{
  # Run's the installation recommended by https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository
  # rather than the default apt-get

  sudo apt-get update \
    && sudo apt-get install -qy \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common \


  # Add Docker's official GPG key:
  sudo apt-get update
  sudo apt-get install ca-certificates curl gnupg
  sudo install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  sudo chmod a+r /etc/apt/keyrings/docker.gpg


  # Add the repository to Apt sources:
  echo \
    "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

  sudo apt-get update

  sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

  # Credential Helper, my config files use it
  sudo apt-get install -qy golang-docker-credential-helpers

  echo "Verify that the Docker Engine installation is successful by running the hello-world image."
  echo "sudo docker run hello-world"
}

install_docker_service

# vim: ts=2 sw=2 sts=0 expandtab :
