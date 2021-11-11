#!/bin/bash

set -e

scriptdir=$(dirname "${BASH_SOURCE[0]}")
scriptdir=$(realpath "${scriptdir}")

package=fltk
version=871e706
depends=(kbproto-1.0.6 libjpeg-turbo-2.0.6 libpng-1.6.37 libX11-1.5.0 libxcb-1.11.1 xproto-7.0.23 zlib-1.2.11)

source "${scriptdir}/config"

src_uri=https://github.com/flederwiesel/fltk.git

rm -rf "${sysrootsdir}"
mkdir -p "${downloaddir}" "${srcdir}" "${sysrootdir}" "${builddir}" "${packagesdir}" "${sysrootsdir}"

if [ -f "${downloaddir}/${package}-${version}.tar.xz" ]; then
	tar xJf "${downloaddir}/${package}-${version}.tar.xz" -C "${srcdir}" --strip-components=1
else
	git clone --depth=1 "${src_uri}" "${srcdir}"
	git -C "${srcdir}" checkout "${version##*-}"
	(
	cd "$srcdir"
	find "$scriptdir/patches/$package-$version" -type f -name "*.patch" |
	while read f
	do
		patch -p 1 < "$f" || exit 1
	done
	)
	ln -s "${srcdir}" "${srcdir}/../${package}-${version}"
	tar cJfh "${downloaddir}/${package}-${version}.tar.xz" -C "${srcdir}/.." "${package}-${version}" || exit 1
	rm "${srcdir}/../${package}-${version}"
fi

for dep in "${depends[@]}"
do
	cp -rlf "${sysrootsdir}/../${dep}/"* "${sysrootdir}"
done

cd "${builddir}"

#PKG_CONFIG="pkg-config --define-prefix" \
#PKG_CONFIG_PATH="${sysrootdir}${libdir}/pkgconfig" \
#LD_FLAGS="-L${sysrootdir}${libdir}" \

cmake "${srcdir}" \
	-DCMAKE_VERBOSE_MAKEFILE=1 \
	-DCMAKE_INSTALL_PREFIX="${prefix}" \
	-DCMAKE_FIND_ROOT_PATH="${sysrootdir}" \
	-DCMAKE_PREFIX_PATH="${sysrootdir}${libdir}/pkgconfig" \
	-DCMAKE_C_FLAGS="-I${sysrootdir}${includedir}" \
	-DCMAKE_CXX_FLAGS="-I${sysrootdir}${includedir}" \
	-DCMAKE_EXE_LINKER_FLAGS="-L${sysrootdir}${libdir} -lxcb" \
	-DFLTK_BUILD_TEST=OFF \

make -j 8
make install DESTDIR="${imagedir}"

tar cJf "${packagesdir}/${package}-${version}.tar.xz" -C "${imagedir}" .
tar xJf "${packagesdir}/${package}-${version}.tar.xz" -C "${sysrootsdir}" --overwrite
