#!/usr/bin/env python3

from conans import ConanFile, tools

import os

class DevelConan(ConanFile):
    settings = 'os'
    description = 'Install Development Tools'
    name = 'devel'
    version = '0.0.1'
    generators = 'virtualenv'

    build_requires = (
        'ccache/[>=4.2.1]'
        'cmake/[>=3.20.2]',
        'ninja/1.10.2',
    )
