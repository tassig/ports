#!/bin/sh -e

package_name=ghostscript
package_version=9.22
tarball_suffix=gz
package_fullname=$package_name-$package_version
ports_build_dependencies="zlib jpeg"
build_dependencies="cups"

url=http://mirrors.tassig.com/$package_name/$package_fullname.tar.$tarball_suffix
installdirectory=/opt
BUILD_DIR=/home/work/

ACTION=$1

function premake(){
	local INCLUDES="-I/opt/zlib/include \
		-I/opt/jpeg/include \
		-I/opt/cups/include \
		"
	sed -i 's/AUXEXTRALIBS=@AUXEXTRALIBS@ @AUX_SHARED_ZLIB@/AUXEXTRALIBS=@AUXEXTRALIBS@ @AUX_SHARED_ZLIB@ -Wl,-rpath,\/opt\/fontconfig\/lib -Wl,-rpath,\/opt\/freetype\/lib/g' Makefile.in
	CFLAGS="$INCLUDES" \
	CXXFLAGS="$INCLUDES" \
	LDFLAGS="-Wl,-rpath,/opt/fontconfig/lib \
		-Wl,-rpath,/opt/freetype/lib \
		-L/opt/zlib/lib \
		-Wl,-rpath,/opt/zlib/lib \
		-L/opt/jpeg/lib \
		-Wl,-rpath,/opt/jpeg/lib \
		-L/opt/cups/lib \
		-Wl,-rpath,/opt/cups/lib \
		" \
		./configure --prefix=/opt/$package_fullname
}

function domake(){
	make
}

function doinstall(){
	make install
}

function postinstall(){
	ln -svf "$installdirectory/$package_fullname" "$installdirectory/$package_name"
	if [ -d "$installdirectory/$package_name/lib/pkgconfig" ]; then
		ln -svf $installdirectory/$package_name/lib/pkgconfig/* \
		$installdirectory/pkgconf/lib/pkgconfig/   # install pkg-config files
	fi
	ln -svf "$installdirectory/$package_name/bin"/* "/bin/"
}

function install_ports_deps(){
	if [ "$ports_build_dependencies" == "" ]; then
		return
	fi
	local START_DIR=`pwd`
	rm -rf "$BUILD_DIR"
	mkdir -p "$BUILD_DIR"
	cd "$BUILD_DIR"

	GIT_SSH_COMMAND="ssh -y" sshpass -p "temppassrobotbuilder" git clone ssh://robotbuilder@git.cacaoweb.org/../var/git/ports.git
	cd ports

	for pkg_name in $ports_build_dependencies
	do
		(./packageinstall.sh $pkg_name) || exit $?
	done

	cd ..
	rm -rf ports
	cd "$START_DIR"
}

function install_deps(){
	if [ "$build_dependencies" == "" ]; then
		return
	fi
	for pkg_name in $build_dependencies
	do
		(./$pkg_name.sh install) || exit $?
	done
}

function install(){
	[ -e "$installdirectory/$package_name" ] && {
		echo "$package_name is already installed"
		exit 0
	}

	install_ports_deps
	install_deps
	local START_DIR=`pwd`
	
	rm -rf "$BUILD_DIR"
	mkdir -p "$BUILD_DIR"
	cd "$BUILD_DIR"

	wget -O archive $url
	tar xvf archive
	rm archive

	cd *
	premake
	domake
	doinstall
	postinstall
	cd "$START_DIR"
}



case $ACTION in
	install)
		install
	;;
	remove)
		remove
	;;
	*)
		echo "$0 <install|remove>"
	;;
esac





