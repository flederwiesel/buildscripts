#!/bin/bash

set -e

scriptdir=$(dirname "${BASH_SOURCE[0]}")
scriptdir=$(realpath "$scriptdir")

source "$scriptdir/config"

[ -f "$sysrootdir/$includedir/mpc.h" ] ||
{
	echo "mpc not found." >&2
	exit 1
}

package=gcc
version=4.8.3

src_uri=http://ftpmirror.gnu.org/${package}/${package}-${version}/${package}-${version}.tar.bz2

rm -rf source/${package}-${version}

mkdir -p download

[ -f "$scriptdir/download/${package}-${version}.tar.gz" ] ||
	wget -nc ${src_uri} -O "download/${package}-${version}.tar.gz"

[ -d "$scriptdir/source/${package}-${version}" ] || {
	mkdir -p source/${package}-${version}
	tar xf "$scriptdir/download/${package}-${version}.tar.gz" -C "$scriptdir/source/${package}-${version}" --strip-components=1

	patch -d "$scriptdir/source/${package}-${version}/gcc/doc/" -p0 < "$scriptdir/patches/gcc-4.8.3-001-gcc.texi.patch"
}

cd "$scriptdir/source/${package}-${version}"

autoconf_version=$(autoconf -V | awk '/^autoconf/ { gsub(/.* /, ""); print $0 }')

sed -i "/dnl Ensure exactly this Autoconf version is used/ {
	a m4_define([_GCC_AUTOCONF_VERSION], [$autoconf_version])
}" config/override.m4

autoconf

HOSTCFLAGS=$(
	grep __GMP_CFLAGS "$sysrootdir/$includedir/gmp.h" |
	cut -d\" -f2 |
	sed s,-pedantic,,
)

CC="$CC" CFLAGS_FOR_TARGET="-O2" CFLAGS="$HOSTCFLAGS" \
CFLAGS_FOR_BUILD="$HOSTCFLAGS" \
./configure \
--target=$TARGET \
--prefix=$prefix --libexecdir=$prefix/lib \
--disable-werror --disable-shared \
--disable-libssp --disable-bootstrap --disable-nls \
--disable-libquadmath --without-headers \
--enable-lto \
--enable-languages="c" \
--with-gmp=$sysrootdir$prefix \
--with-mpfr=$sysrootdir$prefix \
--with-mpc=$sysrootdir$prefix \
--with-libelf=$sysrootdir$prefix \
--with-pkgversion="coreboot toolchain v$CROSSGCC_VERSION $CROSSGCC_DATE"

make $MAKEFLAGS CFLAGS_FOR_BUILD="$HOSTCFLAGS" all-gcc
make install-gcc DESTDIR="$sysrootdir"
