#!/bin/sh

scriptdir=$(dirname "${BASH_SOURCE[0]}")
scriptdir=$(realpath "$scriptdir")

exit 1

wget https://www.libssh.org/files/0.9/libssh-0.9.2.tar.xz -P download
tar xf download/libssh-0.9.2.tar.xz -C source
cd source/libssh-0.9.2/
mkdir build-release
cd build-release/
cmake .. -DCMAKE_INSTALL_PREFIX=/usr
make -j 8
make install DESTDIR="$scriptdir/sysroot"
