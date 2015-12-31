#!/bin/bash

# This script sets up a PPA and installs
# neovim.

add-apt-repository -y ppa:neovim-ppa/unstable
apt-get update
apt-get install -y neovim

# The following dependencies are required for
# python support in neovim:
apt-get install -y python-dev python-pip python3-dev python3-pip

# Then install the python modules:
pip2 install neovim
pip3 install neovim