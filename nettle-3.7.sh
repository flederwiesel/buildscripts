#!/bin/bash

set -e

scriptdir=$(dirname "${BASH_SOURCE[0]}")
scriptdir=$(realpath "${scriptdir}")

package=nettle
version=3.7
depends=(gmp-6.2.1)

source "${scriptdir}/config"

src_uri=https://ftp.gnu.org/gnu/nettle/${package}-${version}.tar.gz

rm -rf "${sysrootsdir}"
mkdir -p "${downloaddir}" "${srcdir}" "${sysrootdir}" "${builddir}" "${packagesdir}" "${sysrootsdir}"

[ -f "${downloaddir}/${package}-${version}.tar.gz" ] ||
	wget -P "${downloaddir}" "${src_uri}"

tar xf "${downloaddir}/${package}-${version}.tar.gz" -C "${srcdir}" --strip-components=1

for dep in "${depends[@]}"
do
	cp -rl "${sysrootsdir}/../${dep}/"* "${sysrootdir}"
done

cd "$builddir"

PKG_CONFIG="pkg-config --define-prefix" \
PKG_CONFIG_PATH="${sysrootdir}${libdir}/pkgconfig" \
"${srcdir}/configure" \
    --prefix="${prefix}" \
	--libdir="${libdir}" \
    --with-include-path="${sysrootdir}${includedir}" \
    --with-lib-path="${sysrootdir}${libdir}" \
    --enable-fast-install \
    --disable-dependency-tracking \
    --enable-static \
    --enable-shared \
    --enable-public-key \
    --enable-x86-aesni \
    --enable-x86-sha-ni \
    --with-gmp \

make -j 8
make install DESTDIR="${imagedir}"

tar cJf "${packagesdir}/${package}-${version}.tar.xz" -C "${imagedir}" .
tar xJf "${packagesdir}/${package}-${version}.tar.xz" -C "${sysrootsdir}"
