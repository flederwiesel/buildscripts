#!/bin/bash

set -e

scriptdir=$(dirname "${BASH_SOURCE[0]}")
scriptdir=$(realpath "${scriptdir}")

package=openssl
version=1.1.1i
depends=(zlib-1.2.11)

source "${scriptdir}/config"

src_uri=https://www.openssl.org/source/${package}-${version}.tar.gz

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

CPPFLAGS="-I${sysrootdir}${includedir}" \
LDFLAGS="-L${sysrootdir}${libdir}" \
"${srcdir}/Configure" \
	--prefix="${prefix}" \
	--libdir="${libdir}" \
	--openssldir="${datadir}/openssl" \
	shared threads zlib-dynamic \
	linux-x86_64

make -j 8
make install DESTDIR="${imagedir}"

tar cJf "${packagesdir}/${package}-${version}.tar.xz" -C "${imagedir}" .
tar xJf "${packagesdir}/${package}-${version}.tar.xz" -C "${sysrootsdir}" --overwrite
