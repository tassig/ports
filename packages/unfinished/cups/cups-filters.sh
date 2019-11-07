#!/bin/sh -e

package_name=cups-filters
package_version=1.20.1
tarball_suffix=xz
package_fullname=$package_name-$package_version
ports_build_dependencies="zlib libjpeg libtiff fontconfig freetype python2"
build_dependencies="cups lcms2 qpdf poppler ghostscript mupdf"

url=http://mirrors.tassig.com/$package_name/$package_fullname.tar.$tarball_suffix
installdirectory=/opt
BUILD_DIR=/home/work/

ACTION=$1

function premake(){
	local INCLUDES="-I/opt/zlib/include \
		-I/opt/libjpeg/include \
		-I/opt/libtiff/include \
		-I/opt/cups/include \
		"
	CFLAGS="$INCLUDES" \
	CXXFLAGS="$INCLUDES" \
	LDFLAGS="-L/opt/zlib/lib -Wl,-rpath,/opt/zlib/lib \
		-L/opt/libjpeg/lib -Wl,-rpath,/opt/libjpeg/lib \
		-L/opt/libtiff/lib -Wl,-rpath,/opt/libtiff/lib \
		-Wl,-rpath,/opt/freetype/lib \
		-Wl,-rpath,/opt/fontconfig/lib \
		-Wl,-rpath,/opt/qpdf/lib \
		-Wl,-rpath,/opt/poppler/lib64 \
		-L/opt/cups/lib \
		-Wl,-rpath,/opt/cups/lib \
		" \
		./configure --prefix=/opt/$package_fullname \
		--disable-dbus \
		--disable-avahi
	sed -i "s/\/\* #undef HAVE_CPP_POPPLER_VERSION_H \*\//#define HAVE_CPP_POPPLER_VERSION_H/g" config.h
	sed -i 's/$(LN_S) -r -f/$(LN_S) -f/g' Makefile
}

function domake(){
	# first call will fail with "/bin/sh: filter/braille/filters/liblouis1.defs.gen: not found"
	make -j || make -j 
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
