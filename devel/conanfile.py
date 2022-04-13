#!/usr/bin/env python3

from conans import ConanFile, CMake, tools
from conans.errors import ConanException

import os

class DevelConan(ConanFile):
    settings = 'os'
    description = 'Install Development Tools'
    name = 'devel'
    version = '0.0.7'
    generators = 'virtualenv'

    build_requires = (
        'ccache/[>=4.2.1]',
        'cmake/[>=3.22]',
        'ninja/1.10.2',
        'gtest/1.11.0',
        'nvim/0.7.0-dev-0115b3f'
    )
