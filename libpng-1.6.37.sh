#!/bin/bash

set -e

scriptdir=$(dirname "${BASH_SOURCE[0]}")
scriptdir=$(realpath "${scriptdir}")

package=libpng
version=1.6.37
depends=(zlib-1.2.11)

source "${scriptdir}/config"

src_uri=https://download.sourceforge.net/libpng/${package}-${version}.tar.xz

rm -rf "${sysrootsdir}"
mkdir -p "${downloaddir}" "${srcdir}" "${sysrootdir}" "${builddir}" "${packagesdir}" "${sysrootsdir}"

[ -f "${downloaddir}/${package}-${version}.tar.xz" ] ||
	wget -P "${downloaddir}" "${src_uri}"

tar xf "${downloaddir}/${package}-${version}.tar.xz" -C "${srcdir}" --strip-components=1

for dep in "${depends[@]}"
do
	cp -rl "${sysrootsdir}/../${dep}/"* "${sysrootdir}"
done

cd "$builddir"

CPPFLAGS="-I${sysrootdir}${includedir}" \
LDFLAGS="-L${sysrootdir}${libdir}" \
"${srcdir}/configure" \
	--prefix="${prefix}" \
	--enable-fast-install \
	--disable-dependency-tracking \
	--enable-shared \

make -j 8
make install DESTDIR="${imagedir}"

tar cJf "${packagesdir}/${package}-${version}.tar.xz" -C "${imagedir}" .
tar xJf "${packagesdir}/${package}-${version}.tar.xz" -C "${sysrootsdir}"
