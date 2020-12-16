#!/bin/bash

set -e

scriptdir=$(dirname "${BASH_SOURCE[0]}")
scriptdir=$(realpath "$scriptdir")

source "$scriptdir/config"

package=gmp
version=5.1.2

src_uri=http://ftpmirror.gnu.org/${package}/${package}-${version}.tar.bz2

rm -rf source/${package}-${version}

mkdir -p download

[ -f "$scriptdir/download/${package}-${version}.tar.gz" ] ||
	wget -q ${src_uri} -O "download/${package}-${version}.tar.gz"

[ -d "$scriptdir/source/${package}-${version}" ] || {
	mkdir -p source/${package}-${version}
	tar xf "$scriptdir/download/${package}-${version}.tar.gz" -C "$scriptdir/source/${package}-${version}" --strip-components=1
}

cd "$scriptdir/source/${package}-${version}"

./configure --build=$BUILD \
	--prefix=$prefix \
	--disable-shared

make $MAKEFLAGS
make install DESTDIR="$sysrootdir"
