#!/bin/sh -e

package_name=mariadb
package_version=10.3.7
tarball_suffix=gz
package_fullname=$package_name-$package_version
ports_build_dependencies="ncurses cmake libressl"
build_dependencies=""

source ./include.sh

function premake(){
	patch -p1 < "$START_DIR/mariadb.patch"
	rm -rf build
	mkdir build
	cd build
	CFLAGS="-I/opt/zlib/include" \
	LDFLAGS="-Wl,-rpath,/opt/ncurses/lib -Wl,-rpath,/opt/libressl/lib" \
	cmake \
		-DCURSES_INCLUDE_PATH=/opt/ncurses/include \
		-DCURSES_LIBRARY=/opt/ncurses/lib/libncurses.so \
		-DPLUGIN_TOKUDB=NO \
		-DCMAKE_INSTALL_PREFIX=/opt/$package_fullname \
		..
}

function domake(){
	export PATH=$PATH:"$START_DIR"
	cd build
	make --trace -j4
	
}

function doinstall(){
	cd build
	make install prefix=/opt/$package_fullname
}

#chmod a+x /home/work/mariadb-10.3.7/build/storage/tokudb/PerconaFT/xz/src/build_lzma/build-aux/install-sh

main

