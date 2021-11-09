#!/bin/bash

set -e

scriptdir=$(dirname "${BASH_SOURCE[0]}")
scriptdir=$(realpath "${scriptdir}")

package=libXi
version=1.6.1
depends=(xproto-7.0.23 libX11-1.5.0 xextproto-7.2.1 libXext-1.3.1 inputproto-2.2 kbproto-1.0.6 libxcb-1.8.1 libXau-1.0.7 libpthread-stubs-0.4)

source "${scriptdir}/config"

src_uri=https://www.x.org/releases/X11R7.7/src/lib/${package}-${version}.tar.bz2

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
CPPFLAGS="-I${sysrootdir}${includedir}" \
LDFLAGS="-L${sysrootdir}${libdir}" \
"${srcdir}/configure" \
	--prefix="${prefix}" \
	--enable-fast-install \
	--disable-dependency-tracking \
	--enable-shared \
	--with-sysroot="${sysrootdir}" \

make -j 8
make install DESTDIR="${imagedir}"

tar cJf "${packagesdir}/${package}-${version}.tar.xz" -C "${imagedir}" .
tar xJf "${packagesdir}/${package}-${version}.tar.xz" -C "${sysrootsdir}" --overwrite
