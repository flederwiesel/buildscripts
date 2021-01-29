#!/bin/sh

scriptdir=$(dirname "${BASH_SOURCE[0]}")
scriptdir=$(realpath "$scriptdir")

# https://solarianprogrammer.com/2016/10/07/building-gcc-ubuntu-linux/
# https://gcc.gnu.org/install/index.html

version=8.2.0

rm -rf source/gcc-${version}

mkdir -p download
mkdir -p source/gcc-${version}

[ -f "$scriptdir/download/gcc-${version}.tar.gz" ] ||
	wget https://ftpmirror.gnu.org/gcc/gcc-${version}/gcc-${version}.tar.gz -O "download/gcc-${version}.tar.gz"

[ -d "$scriptdir/source/gcc-${version}" ] ||
	tar xf "$scriptdir/download/gcc-${version}.tar.gz" -C "$scriptdir/source/gcc-${version}" --strip-components=1

cd "$scriptdir/source/gcc-${version}"

(
cd src
contrib/download_prerequisites --directory=../downloads --verify
)

mkdir build-x86_64

(
cd build-x86_64
../src/configure -v \
    --build=x86_64-linux-gnu \
    --host=x86_64-linux-gnu \
    --target=x86_64-linux-gnu \
    --prefix=/usr/local/gcc-8.2 \
    --enable-checking=release \
    --enable-languages=c,c++,fortran,go \
    --disable-multilib \
    --program-suffix=-8.2

make -j 8
#sudo make install
make install DESTDIR=/tmp/gcc-${version}-x86_64
)

mkdir build-i386

(
cd build-i386
../src/configure -v \
    --build=x86_64-linux-gnu \
    --host=x86_64-linux-gnu \
    --target=i386-linux-gnu \
    --prefix=/usr/local/gcc-8.2 \
    --enable-checking=release \
    --enable-languages=c,c++,fortran,go \
    --disable-multilib \
    --program-suffix=-8.2

make -j 8
#sudo make install
make install DESTDIR=/tmp/gcc-${version}-x86_64
)
