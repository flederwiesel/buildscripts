#!/bin/bash

set -e

scriptdir=$(dirname "${BASH_SOURCE[0]}")
scriptdir=$(realpath "${scriptdir}")

package=gnutls
version=3.6.15
depends=(gmp-6.2.1 libunistring-0.9.10 nettle-3.7)

source "${scriptdir}/config"

src_uri=https://www.gnupg.org/ftp/gcrypt/gnutls/v${version%.*}/${package}-${version}.tar.xz

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
PKG_CONFIG="pkg-config --define-prefix" \
PKG_CONFIG_PATH="${sysrootdir}${libdir}/pkgconfig:${sysrootdir}${prefix}/lib64/pkgconfig" \
"${srcdir}/configure" \
	--prefix="${prefix}" \
	--libdir="${libdir}" \
	--with-sysroot="${sysrootdir}" \
	--enable-fast-install \
	--disable-dependency-tracking \
	--enable-shared \
	--disable-maintainer-mode \
	--enable-openssl-compatibility \
	--enable-manpages \
	--disable-tests \
	--disable-libdane \
	--without-p11-kit \
	--with-included-libtasn1 \

make -j 8
make install DESTDIR="${imagedir}"

tar cJf "${packagesdir}/${package}-${version}.tar.xz" -C "${imagedir}" .
tar xJf "${packagesdir}/${package}-${version}.tar.xz" -C "${sysrootsdir}"
