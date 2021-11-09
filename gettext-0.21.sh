#!/bin/bash

set -e

scriptdir=$(dirname "${BASH_SOURCE[0]}")
scriptdir=$(realpath "${scriptdir}")

package=gettext
version=0.21
depends=(libiconv-1.16 ncurses-6.2)

source "${scriptdir}/config"

src_uri=https://ftp.gnu.org/pub/gnu/gettext/${package}-${version}.tar.gz

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
	--disable-dependency-tracking \
	--enable-fast-install \
	--enable-shared \
	--disable-java \
	--disable-csharp \
	--disable-c++ \
	--with-libiconv-prefix="${sysrootdir}" \
	--with-libintl-prefix="${sysrootdir}" \
	--with-libncurses-prefix="${sysrootdir}" \
	--with-libtermcap-prefix="${sysrootdir}" \
	--without-included-regex

make -j 8
make install DESTDIR="${imagedir}"

tar cJf "${packagesdir}/${package}-${version}.tar.xz" -C "${imagedir}" .
tar xJf "${packagesdir}/${package}-${version}.tar.xz" -C "${sysrootsdir}" --overwrite
