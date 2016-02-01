#!/bin/bash

# This script installs Sphinx, the document creation tool.
apt-get install -y python-pip texlive texlive-latex-extra texlive-fonts-recommended
pip install -U Sphinx
