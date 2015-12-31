#!/bin/bash

# This script is used to install all of the
# tools that the system-setup-scripts provide.

# See if git is installed:
hash git 2>/dev/null || { echo "Error: git is not installed. Please install git first."; exit 1;}

mkdir -p /opt
INSTALL_DIR=/opt/system-setup-scripts

if [ ! -d ${INSTALL_DIR} ]; then
  git clone https://github.com/jmdaly/system-setup-scripts ${INSTALL_DIR}
fi

cd ${INSTALL_DIR}
git pull

files=(*.sh)

# Install everything:
for f in ${files[*]}; do
  echo "Executing $f"
  eval "${INSTALL_DIR}/$f"
done; 
