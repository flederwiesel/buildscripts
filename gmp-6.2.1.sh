#!/bin/bash

set -e

scriptdir=$(dirname "${BASH_SOURCE[0]}")
scriptdir=$(realpath "${scriptdir}")

package=gmp
version=6.2.1
depends=()

source "${scriptdir}/config"

src_uri=https://gmplib.org/download/gmp/${package}-${version}.tar.lz

rm -rf "${sysrootsdir}"
mkdir -p "${downloaddir}" "${srcdir}" "${sysrootdir}" "${builddir}" "${packagesdir}" "${sysrootsdir}"

[ -f "${downloaddir}/${package}-${version}.tar.lz" ] ||
	wget -P "${downloaddir}" "${src_uri}"

tar --lzip -xf "${downloaddir}/${package}-${version}.tar.lz" -C "${srcdir}" --strip-components=1

for dep in "${depends[@]}"
do
	cp -rlf "${sysrootsdir}/../${dep}/"* "${sysrootdir}"
done

cd "$builddir"

"${srcdir}/configure" \
	--prefix="${prefix}" \
	--libdir="${libdir}" \
	--enable-fast-install \
	--disable-dependency-tracking \
	--enable-shared

make -j 8
make install DESTDIR="${imagedir}"

tar cJf "${packagesdir}/${package}-${version}.tar.xz" -C "${imagedir}" .
tar xJf "${packagesdir}/${package}-${version}.tar.xz" -C "${sysrootsdir}" --overwrite
