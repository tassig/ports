#!/bin/sh -e

package_name=hplip
package_version=3.18.6
tarball_suffix=gz
package_fullname=$package_name-$package_version
ports_build_dependencies="libjpeg gawk perl"
build_dependencies=""

source ./include.sh

function premake(){
	patch -p1 < "$START_DIR/hpijs-drv.patch"
	CFLAGS="-I/opt/jpeg/include \
		" \
	LDFLAGS="-L/opt/libjpeg/lib \
		-Wl,-rpath,/opt/libjpeg/lib \
		" \
	./configure --prefix=/opt/$package_fullname
}

#function domake(){
#	make --trace
#}

main
