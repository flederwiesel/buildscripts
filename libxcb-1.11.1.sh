#!/bin/bash

set -e

scriptdir=$(dirname "${BASH_SOURCE[0]}")
scriptdir=$(realpath "${scriptdir}")

package=libxcb
version=1.11.1
depends=(libpthread-stubs-0.4 libXau-1.0.7 xcb-proto-1.11 xproto-7.0.23)

source "${scriptdir}/config"

src_uri=https://xcb.freedesktop.org/dist/${package}-${version}.tar.bz2

rm -rf "${sysrootsdir}"
mkdir -p "${downloaddir}" "${srcdir}" "${sysrootdir}" "${builddir}" "${packagesdir}" "${sysrootsdir}"

[ -f "${downloaddir}/${package}-${version}.tar.bz2" ] ||
	wget -P "${downloaddir}" "${src_uri}"

tar xf "${downloaddir}/${package}-${version}.tar.bz2" -C "${srcdir}" --strip-components=1

for dep in "${depends[@]}"
do
	cp -rlf "${sysrootsdir}/../${dep}/"* "${sysrootdir}"
done

cd "$builddir"

PKG_CONFIG="pkg-config --define-prefix" \
PKG_CONFIG_PATH="${sysrootdir}${libdir}/pkgconfig" \
"${srcdir}/configure" \
	--prefix="${prefix}" \
	--enable-shared \
	--enable-fast-install \
	--disable-dependency-tracking

make -j 8
make install DESTDIR="${imagedir}"

tar cJf "${packagesdir}/${package}-${version}.tar.xz" -C "${imagedir}" .
tar xJf "${packagesdir}/${package}-${version}.tar.xz" -C "${sysrootsdir}" --overwrite
