#!/usr/bin/env python3

from conans import ConanFile, CMake, tools
from conans.errors import ConanException

import os

class DevelConan(ConanFile):
    settings = 'os'
    description = 'Install Development Tools'
    name = 'devel'
    version = '0.0.2'
    generators = 'virtualenv'

    build_requires = (
        'ccache/[>=4.2.1]@matt/testing',
        'cmake/[>=3.20.2]',
        'ninja/1.10.2',
        'gtest/1.10.0',
        'nvim/0.5.0-dev-056c464e@matt/nightly',
    )
