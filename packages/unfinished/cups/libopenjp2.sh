#!/bin/sh -e

package_name=libopenjp2
package_version=2.3.0
tarball_suffix=gz
package_fullname=$package_name-$package_version
ports_build_dependencies="libtiff libpng zlib"
build_dependencies="lcms2"

url=http://mirrors.tassig.com/$package_name/$package_fullname.tar.$tarball_suffix
installdirectory=/opt
BUILD_DIR=/home/work/

ACTION=$1

function premake(){
	mkdir build
	cd build
	
	LDFLAGS="-Wl,-rpath,/opt/zlib/lib \
		-Wl,-rpath,/opt/libtiff/lib \
		-Wl,-rpath,/opt/lcms2/lib \
		-Wl,-rpath,/opt/libpng/lib \
		-Wl,-rpath,/opt/libopenjp2/lib \
		" \
	cmake -DCMAKE_INSTALL_PREFIX=$installdirectory/$package_fullname \
		-DZLIB_INCLUDE_DIR=/opt/zlib/include \
		-DTIFF_LIBRARY=/opt/libtiff/lib/libtiff.so \
		-DTIFF_INCLUDE_DIR=/opt/libtiff/include \
		-DLCMS2_LIBRARY=/opt/lcms2/lib/liblcms2.so \
		-DLCMS2_INCLUDE_DIR=/opt/lcms2/include \
		-DPNG_LIBRARY=/opt/libpng/lib/libpng.so \
		-DPNG_PNG_INCLUDE_DIR=/opt/libpng/include \
		.. 
	
}

function domake(){
	make -j
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





