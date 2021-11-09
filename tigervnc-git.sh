#!/bin/bash

set -e

scriptdir=$(dirname "${BASH_SOURCE[0]}")
scriptdir=$(realpath "${scriptdir}")

package=tigervnc
version=6bc7ae9
#pixman-0.40.0
depends=(fltk-871e706 gettext-0.21 gmp-6.2.1 gnutls-3.6.15 kbproto-1.0.6 libjpeg-turbo-2.0.6 libpng-1.6.37 libX11-1.5.0 libxcb-1.8.1 libXtst-1.2.1 Linux-PAM-1.5.1 nettle-3.7 xextproto-7.2.1 xproto-7.0.23 zlib-1.2.11)

source "${scriptdir}/config"

src_uri=https://github.com/flederwiesel/tigervnc.git

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
	tar cJfh "${downloaddir}/${package}-${version}.tar.xz" -C "${srcdir}/.." "${package}-${version}"
	rm "${srcdir}/../${package}-${version}"
fi

for dep in "${depends[@]}"
do
	cp -rlf "${sysrootsdir}/../${dep}/"* "${sysrootdir}"
done

cd "${builddir}"

LDFLAGS="-L${sysrootdir}${baselibdir_mutiarch} -L${sysrootdir}${libdir} -lxcb" \
cmake "${srcdir}" \
	-DCMAKE_VERBOSE_MAKEFILE=1 \
	-DCMAKE_INSTALL_PREFIX="${prefix}" \
	-DCMAKE_FIND_ROOT_PATH="${sysrootdir}" \
	-DCMAKE_PREFIX_PATH="${sysrootdir}${libdir}/pkgconfig:${sysrootdir}/lib64/pkgconfig" \
	-DCMAKE_C_FLAGS="-I${sysrootdir}${includedir}" \
	-DCMAKE_CXX_FLAGS="-I${sysrootdir}${includedir}" \

make -j 8
make install DESTDIR="${imagedir}"

tar cJf "${packagesdir}/${package}-${version}.tar.xz" -C "${imagedir}" .
tar xJf "${packagesdir}/${package}-${version}.tar.xz" -C "${sysrootsdir}" --overwrite
