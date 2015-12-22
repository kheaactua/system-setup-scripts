#!/bin/bash

# This script is used to install the tools to
# generate flame graphs for CPU profiling.

apt-get update
apt-get install -y linux-tools-common

INSTALL_PREFIX=/opt

if [ ! -d ${INSTALL_PREFIX}/FlameGraph ]; then
  mkdir -p ${INSTALL_PREFIX}
  cd ${INSTALL_PREFIX}
  git clone --depth 1 https://github.com/brendangregg/FlameGraph
fi

cd ${INSTALL_PREFIX}/FlameGraph
git pull
