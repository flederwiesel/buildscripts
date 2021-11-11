#!/bin/bash

set -e

scriptdir=$(dirname "${BASH_SOURCE[0]}")
scriptdir=$(realpath "${scriptdir}")

package=ncurses
version=6.3
depends=(termcap-1.3.1)

source "${scriptdir}/config"

src_uri=ftp://ftp.gnu.org/gnu/ncurses/${package}-${version}.tar.gz

rm -rf "${sysrootsdir}"
mkdir -p "${downloaddir}" "${srcdir}" "${sysrootdir}" "${builddir}" "${packagesdir}" "${sysrootsdir}"

[ -f "${downloaddir}/${package}-${version}.tar.gz" ] ||
	wget -P "${downloaddir}" "${src_uri}"

tar xf "${downloaddir}/${package}-${version}.tar.gz" -C "${srcdir}" --strip-components=1

for dep in "${depends[@]}"
do
	cp -rlf "${sysrootsdir}/../${dep}/"* "${sysrootdir}"
done

cd "$builddir"

"${srcdir}/configure" \
	--prefix="${prefix}" \
	--datadir="${datadir}" \
	--enable-rpath \
	--enable-ext-colors \
	--enable-termcap \
	--enable-pc-files \
	--with-abi-version=5 \
	--with-shared \
	--without-ada --without-cxx --without-cxx-binding \
	--without-manpages --without-tests --without-develop \

make -j 8
make install DESTDIR="${imagedir}"

tar cJf "${packagesdir}/${package}-${version}.tar.xz" -C "${imagedir}" .
tar xJf "${packagesdir}/${package}-${version}.tar.xz" -C "${sysrootsdir}" --overwrite
