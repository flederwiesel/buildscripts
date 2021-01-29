#!/bin/bash

set -e

scriptdir=$(dirname "${BASH_SOURCE[0]}")
scriptdir=$(realpath "${scriptdir}")

package=kbproto
version=1.0.6
depends=()

source "${scriptdir}/config"

src_uri=https://www.x.org/releases/X11R7.7/src/proto/${package}-${version}.tar.gz

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

"${srcdir}/configure" \
	--prefix="${prefix}"

make -j 8
make install DESTDIR="${imagedir}"

tar cJf "${packagesdir}/${package}-${version}.tar.xz" -C "${imagedir}" .
tar xJf "${packagesdir}/${package}-${version}.tar.xz" -C "${sysrootsdir}"
