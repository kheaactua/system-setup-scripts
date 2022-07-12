#!/usr/bin/env python3

from conans import ConanFile, CMake, tools
from conans.errors import ConanException

import os

class DevelConan(ConanFile):
    settings = 'os'
    description = 'Install Development Tools'
    name = 'devel'
    version = '0.0.11'
    generators = 'virtualenv'

    build_requires = (
        'ccache/[>=4.6]',
        'cmake/[>=3.23]',
        'ninja/[>=1.10.2]',
        'gtest/1.11.0',
        # 'nvim/v0.7.0-333ba65'
    )
