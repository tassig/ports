#!/bin/sh -e

package_name=wireshark
package_version=2.6.0
tarball_suffix=xz
package_fullname=$package_name-$package_version
ports_build_dependencies="python2 perl libpcap"
build_dependencies="libgcrypt"

source ./include.sh

function premake(){
	CFLAGS="-I/opt/libpcap/include \
		-I/opt/libpcap/include/pcap \
		-I/opt/libgcrypt/include \
		-I/opt/libgpg-error/include \
		"\
	./configure --prefix=/opt/$package_fullname --with-qt=no --with-gtk=2
}

#function domake(){
#	make --trace
#}

main
