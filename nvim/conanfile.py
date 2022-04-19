#!/usr/bin/env python3

from conans import ConanFile, AutoToolsBuildEnvironment, tools
from conans.errors import ConanException
import pycurl
import json
from io import BytesIO

import os


class NvimConan(ConanFile):
    """
    Recall, to strip the name and type, build with
    conan create . nvim/v0.8.0-dev+12-147cc60@_/_
    """
    settings = 'os'
    description = 'Install neovim 0.7.0 nightly'
    name = 'nvim'
    build_requires = (
        'cmake/[>=3.22.0]',
        'ninja/1.10.2',
    )

    def init(self):
        self._commitish = None

    def set_version(self):
        self.version = f'v0.8.0-dev+12-{self.commitish:7.7}'

    @property
    def commitish(self):
        if self._commitish is None:
            self._commitish = self.get_nightly_commitish()
        return self._commitish

    @staticmethod
    def get_nightly_commitish():
        b_obj = BytesIO()
        crl = pycurl.Curl()

        # Set URL value
        crl.setopt(crl.URL, 'https://api.github.com/repos/neovim/neovim/releases/tags/nightly')

        # Do I need an accept header?
        # "Accept: application/vnd.github.v3+json"

        # Write bytes that are utf-8 encoded
        crl.setopt(crl.WRITEDATA, b_obj)

        # Perform a file transfer
        crl.perform()

        # End curl session
        crl.close()

        # Get the content stored in the BytesIO object (in byte characters)
        get_body = b_obj.getvalue()

        # Decode the bytes stored in get_body to HTML and print the result
        data = json.loads(get_body.decode('utf8'))

        return data['target_commitish']

    def system_requirements(self):
        pack_names = None
        if 'ubuntu' == tools.os_info.linux_distro:
            if tools.os_info.os_version >= '16':
                pack_names = ['libtool-bin']

        if pack_names:
            installer = tools.SystemPackageTool()
            try:
                installer.update() # Update the package database
                installer.install(' '.join(pack_names)) # Install the package
            except ConanException:
                self.output.warn('Could not run system requirements installer.  Required packages might be missing.')

    def source(self):
        git = tools.Git(folder='neovim')
        git.clone('https://github.com/neovim/neovim')
        git.checkout(self.commitish)

    def build(self):
        with tools.chdir('./neovim'):
            env_build = AutoToolsBuildEnvironment(self)
            env_build.make(args=[
                'CMAKE_BUILD_TYPE=Release',
                f'CMAKE_INSTALL_PREFIX={self.package_folder}'
            ])

    def package(self):
        with tools.chdir('./neovim'):
            env_build = AutoToolsBuildEnvironment(self)
            env_build.install()
        bin_path = os.path.join(self.package_folder, 'bin')
        os.symlink(src=os.path.join(bin_path, 'nvim'), dst=os.path.join(bin_path, 'vi'))
        os.symlink(src=os.path.join(bin_path, 'nvim'), dst=os.path.join(bin_path, 'vim'))

    def package_info(self):
        self.env_info.PATH.append(os.path.join(self.package_folder, 'bin'))
