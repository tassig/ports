#!/bin/sh -e

package_name=poppler
package_version=0.62.0
tarball_suffix=xz
package_fullname=$package_name-$package_version
ports_build_dependencies="cmake zlib libjpeg freetype libpng libtiff fontconfig glib perl"
build_dependencies="poppler-data libopenjp2 lcms2 libiconv"

url=http://mirrors.tassig.com/$package_name/$package_fullname.tar.$tarball_suffix
installdirectory=/opt
BUILD_DIR=/home/work/

ACTION=$1

function premake(){
	mkdir build
	cd build
	
	LDFLAGS="-Wl,-rpath,/opt/freetype/lib \
		-Wl,-rpath,/opt/libjpeg/lib \
		-Wl,-rpath,/opt/zlib/lib \
		-Wl,-rpath,/opt/libpng/lib \
		-Wl,-rpath,/opt/libtiff/lib \
		-Wl,-rpath,/opt/lcms2/lib/liblcms2.so \
		-Wl,-rpath,/opt/libiconv/lib \
		-Wl,-rpath,/opt/nss/lib \
		-L/opt/nss/lib \
		-L/opt/nspr/lib \
		-Wl,-rpath,/opt/nspr/lib \
		-Wl,-rpath,/opt/libopenjp2/lib \
		-L/opt/libopenjp2/lib \
		-L/opt/glib/lib \
		-Wl,-rpath,/opt/glib/lib \
		-Wl,-rpath,/opt/poppler/lib64 \
		" \
	cmake -DCMAKE_INSTALL_PREFIX=$installdirectory/$package_fullname \
		-DFREETYPE_LIBRARY=/opt/freetype/lib/libfreetype.so \
		-DFREETYPE_INCLUDE_DIRS=/opt/freetype/include/freetype2 \
		-DJPEG_LIBRARY=/opt/libjpeg/lib/libjpeg.so \
		-DJPEG_INCLUDE_DIR=/opt/libjpeg/include \
		-DZLIB_INCLUDE_DIR=/opt/zlib/include \
		-DPNG_LIBRARY=/opt/libpng/lib/libpng.so \
		-DPNG_PNG_INCLUDE_DIR=/opt/libpng/include \
		-DTIFF_LIBRARY=/opt/libtiff/lib/libtiff.so \
		-DTIFF_INCLUDE_DIR=/opt/libtiff/include \
		-DICONV_LIBRARIES=/opt/libiconv/lib/libiconv.so \
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
	if [ -d "$installdirectory/$package_name/lib64/pkgconfig" ]; then
		ln -svf $installdirectory/$package_name/lib64/pkgconfig/* \
		$installdirectory/pkgconf/lib/pkgconfig/   # install pkg-config files
	fi
	ln -svf "$installdirectory/$package_name/bin"/* "/bin/"
	
	cp -v ../poppler/*.h /opt/poppler/include/poppler/
	cp -v ./poppler/*.h /opt/poppler/include/poppler/
	mkdir /opt/poppler/include/poppler/goo
	cp -v ../goo/*.h /opt/poppler/include/poppler/goo
	mkdir /opt/poppler/include/poppler/splash
	cp -v ../splash/*.h /opt/poppler/include/poppler/splash/
	ln -s /opt/poppler/include/poppler /opt/poppler/include/poppler/poppler
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




