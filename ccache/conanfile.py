#!/usr/bin/env python3

from conans import ConanFile, CMake, tools
from conans.errors import ConanException

import os

class CcacheConan(ConanFile):
    """
    Right now deply calls self.copy, this annoys me in two ways:
    - I would prefer to simply re-call CMake's install such that I don't need
      to create my own primitive install process
    - I would also prefer to call something like checkinstall in order to make
      this a uninstallable package.

    Also note the downloading caching in this package is a little overkill,
    it's like this simlpy because of my history with building a lot of conan
    packages and wanting caching to save time.
    """

    settings = 'os'
    description = 'Install ccache'
    name = 'ccache'
    version = '4.2.1'
    requires = 'helpers/0.3@matt/stable',
    md5_has = '0f95a4b491a4dcd904c8235ee7c660cd'
    no_copy_source = True


    def system_requirements(self):
        pack_names = None
        if 'ubuntu' == tools.os_info.linux_distro:
            if tools.os_info.os_version >= '16':
                pack_names = ['libzstd-dev']

        if pack_names:
            installer = tools.SystemPackageTool()
            try:
                installer.update() # Update the package database
                installer.install(' '.join(pack_names)) # Install the package
            except ConanException:
                self.output.warn('Could not run system requirements installer.  Required packages might be missing.')

    def source(self):
        archive_ext = '.tar.xz'
        archive_name = f'ccache-{self.version}'
        archive_file = f'{archive_name}.{archive_ext}'

        from source_cache import copyFromCache
        if copyFromCache(archive_file):
            tools.unzip(archive_file)
            shutil.move(archive_name, self.name)
        else:
            try:
                if not os.path.exists(archive_file):
                    # Sometimes the file can already exist
                    tools.download(
                        url=f'https://github.com/ccache/ccache/releases/download/v{self.version}/{archive_file}',
                        filename=archive_file
                    )
                    tools.check_md5(archive_file, self.md5_hash)
                tools.unzip(archive_file)
                shutil.move(archive_name, self.name)
            except ConanException as e:
                self.output.warn('Received exception while downloding ccache archive.  Attempting to clone from source. Exception = %s'%e)
                self.run(f'git clone https://github.com/ccache/ccache {self.name}')
                self.run(f'cd {self.name} && git checkout v{self.version}')

    def _set_up_cmake(self):
        cmake = CMake(self, generator='Unix Makefiles')
        cmake.definitions['CMAKE_BUILD_TYPE'] = 'Release'
        return cmake

    def build(self):
        cmake = self._set_up_cmake()
        cmake.configure(source_folder=self.name)
        cmake.build()

    def package(self):
        cmake = self._set_up_cmake()
        cmake.install()

    def deploy(self):
        # I don't like that this ignores cmake's install, breaking encapsulation
        self.copy('*', src='bin', dst='/usr/local/bin')
        # self.run(f'checkinstall -D -y --pkgname ccache --pkgversion "{self.version}" --pkggroup tools make install')
