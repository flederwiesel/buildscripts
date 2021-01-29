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

package=mpfr
version=3.1.2

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

HOSTCFLAGS=$(
	grep __GMP_CFLAGS "$sysrootdir/$includedir/gmp.h" |
	cut -d\" -f2 |
	sed s,-pedantic,,
)

./configure --build=$BUILD \
	--prefix=$prefix \
	--infodir=$datadir/info \
	--disable-shared \
	--with-gmp=$sysrootdir CFLAGS="$HOSTCFLAGS"

make $MAKEFLAGS
make install DESTDIR="$sysrootdir"
