#!/usr/bin/env python3

from conan import ConanFile


class DevelConan(ConanFile):
    settings = 'os'
    description = 'Install Development Tools'
    name = 'devel'
    version = '0.0.13'
    generators = 'VirtualRunEnv'

    tool_requires = (
        'ccache/[>=4.8]',
        # 'cmake/[>=3.25]',
        'ninja/[>=1.10.2]',
        # 'gtest/1.11.0',
        # 'nvim/v0.7.0-333ba65'
    )

    requires = (
        'ccache/[>=4.8]',
        'cmake/[>=3.21]',
        'ninja/[>=1.10.2]',
    )
