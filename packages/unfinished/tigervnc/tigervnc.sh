#!/bin/sh

package_name=tigervnc
package_version=1.7.0
url=http://mirrors.tassig.com/tigervnc/tigervnc-1.7.0.tar.gz

set -ex

# check if cmake is installed
cmake > /dev/null || {
	echo "please, install cmake from ports"
	exit 1
}

./fltk.sh

[ -L /opt/tigervnc ] && exit 0

# clean build dir
rm -rf builddir || true

mkdir -p builddir
cd builddir

wget $url -O archive

tar xf archive
rm archive

cd *

# tigervnc have hardcoded paths to search libs/headers
# so we need to point it to the right places
# the same goes to linker flags
# Without CMAKE_CXX_FLAGS build will be failed at some point: looks like
# at some point CMAKE_INCLUDE_PATH will be overridden
# TODO: this is not using libressl, so stream encryption will not be supported (it doesn't really matter anyway, because we can always run in an ssh tunnel if we want)
CMAKE_INCLUDE_PATH="/opt/libjpeg/include:/opt/fltk/include" \
	CMAKE_LIBRARY_PATH="/opt/libjpeg/lib:/opt/fontconfig/lib:\
		/opt/fltk/lib:/opt/gcc-6.1.0/x86_64-longhorn-linux-musl/lib/:\
		/opt/libpng/lib: \
		/opt/gettext/lib" \
	cmake \
		-DCMAKE_EXE_LINKER_FLAGS="-L/opt/gettext/lib -lintl -L/opt/libpng/lib -lpng16 -Wl,-rpath,/opt/xorg/lib:/opt/fontconfig/lib:/opt/libjpeg/lib:/opt/libressl/lib:/opt/libpng/lib:/opt/gettext/lib -static-libgcc -static-libstdc++" \
		-DCMAKE_INSTALL_PREFIX:PATH=/opt/$package_name-$package_version/ \
		-DZLIB_ROOT:PATH=/opt/zlib/ \
		-DCMAKE_CXX_FLAGS="-I/opt/xorg/include" \
		-DICONV_INCLUDE_DIR="/opt/gcc-6.1.0/x86_64-longhorn-linux-musl/include/" \
		-DGETTEXT_INCLUDE_DIR=/opt/gettext/include \
		.
make
make install

cd ../..

# cleanup builddir
rm -rf builddir

# symlinks
ln -svf /opt/tigervnc-1.7.0 /opt/tigervnc 
ln -svf /opt/tigervnc/bin/* /bin/ 
