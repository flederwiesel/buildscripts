#!/bin/bash

set -e

scriptdir=$(dirname "${BASH_SOURCE[0]}")
scriptdir=$(realpath "${scriptdir}")

package=glibc
version=2.32
depends=()

source "${scriptdir}/config"

src_uri=https://ftp.gnu.org/gnu/glibc/${package}-${version}.tar.xz

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

"${srcdir}/configure" \
	--prefix="${prefix}" \
	--libdir="${libdir}" \
	--enable-fast-install \
	--disable-dependency-tracking \
	--enable-shared \
	--enable-stack-protector=strong \

make -j 8
make install DESTDIR="${imagedir}"

tar cJf "${packagesdir}/${package}-${version}.tar.xz" -C "${imagedir}" .
tar xJf "${packagesdir}/${package}-${version}.tar.xz" -C "${sysrootsdir}"
