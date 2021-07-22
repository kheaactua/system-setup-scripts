#!/usr/bin/env python3

from conans import ConanFile, CMake, tools
from conans.errors import ConanException

import os

class DevelConan(ConanFile):
    settings = 'os'
    description = 'Install Development Tools'
    name = 'devel'
    version = '0.0.3'
    generators = 'virtualenv'

    build_requires = (
        'ccache/[>=4.2.1]',
        'cmake/[>=3.20.4]',
        'ninja/1.10.2',
        'gtest/1.10.0',
        'nvim/0.5.0-dev-6f48c018',
    )
