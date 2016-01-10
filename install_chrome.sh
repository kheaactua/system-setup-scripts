#!/bin/bash

# This script sets up and installs Google Chrome.

# See if chrome is already installed:
if [ ! -f /etc/apt/sources.list.d/google-chrome.list ]; then
  echo "deb http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list
  # Get the key:
  wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add -
fi

apt-get update
apt-get install -y google-chrome-stable
