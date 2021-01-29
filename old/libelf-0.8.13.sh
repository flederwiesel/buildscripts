#!/bin/bash

set -e

scriptdir=$(dirname "${BASH_SOURCE[0]}")
scriptdir=$(realpath "$scriptdir")

source "$scriptdir/config"

[ -f "$sysrootdir/$includedir/gmp.h" ] ||
{
	echo "gmp not found." >&2
	exit 1
}

package=libelf
version=0.8.13

src_uri=https://fossies.org/linux/misc/old/${package}-${version}.tar.gz

rm -rf source/${package}-${version}

mkdir -p download

[ -f "$scriptdir/download/${package}-${version}.tar.gz" ] ||
	wget -q ${src_uri} -O "download/${package}-${version}.tar.gz"

[ -d "$scriptdir/source/${package}-${version}" ] || {
	mkdir -p source/${package}-${version}
	tar xf "$scriptdir/download/${package}-${version}.tar.gz" -C "$scriptdir/source/${package}-${version}" --strip-components=1
}

cd "$scriptdir/source/${package}-${version}"

HOSTCFLAGS=$(
	grep __GMP_CFLAGS "$sysrootdir/$includedir/gmp.h" |
	cut -d\" -f2 |
	sed s,-pedantic,,
)

CFLAGS="$HOSTCFLAGS" libelf_cv_elf_h_works=no \
./configure --build=$BUILD \
	--prefix=/usr \
	--infodir=$datadir/info \
	--disable-shared \
	CFLAGS="$HOSTCFLAGS"

make $MAKEFLAGS
make install prefix="$sysrootdir"
