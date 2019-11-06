#!/bin/sh -e

package_name=cndrvcups-capt
package_version=2.71-1
tarball_suffix=gz
package_fullname=$package_name-$package_version
ports_build_dependencies=""
build_dependencies=cndrvcups-common

url=http://mirrors.tassig.com/$package_name/$package_fullname.tar.$tarball_suffix
installdirectory=/opt
BUILD_DIR=/home/work/

ACTION=$1

function premake(){
	local INCLUDES="-I$installdirectory/cups/include \
		-I$installdirectory/cndrvcups-common/include \
		-I$installdirectory/libxml2/include/libxml2 \
		"


	echo "--- a/allgen.sh
+++ b/allgen.sh
@@ -1,13 +1,14 @@
-_prefix=/usr
-_bindir=/usr/bin
+#!/bin/sh -x
+_prefix=$installdirectory/$package_fullname
+_bindir=$installdirectory/$package_fullname/bin
 
 PARAMETER=\$1
 
 if [ \`uname -m\` != \"x86_64\" ]
 then
-	_locallibs=/usr/local/lib
+	_locallibs=$installdirectory/$package_fullname/lib
 else
-	_locallibs=/usr/local/lib64
+	_locallibs=$installdirectory/$package_fullname/lib64
 fi
 
 cd cngplp
@@ -57,9 +58,8 @@
 elif [ -x /usr/bin/automake-1.9 ] ; then
 	./autogen.sh
 else
-	./autogen-old.sh
+	./autogen.sh
 fi
 
 cd -
-make
 
" | patch -p1

	echo '--- a/statusui/src/ppapdata.c
+++ b/statusui/src/ppapdata.c
@@ -23,6 +23,7 @@
 #include <string.h>
 
 #include <cups/cups.h>
+#include <cups/ppd.h>
 #include "uimain.h"
 #include "cnsktmodule.h"
 
' | patch -p1

	sed -i 's/captstatusui_LDADD = -lgtk-x11-2.0/captstatusui_LDADD = -lgtk-x11-2.0 -lgdk-x11-2.0 -latk-1.0 -lgdk_pixbuf-2.0 -lglade-2.0/g' statusui/src/Makefile.am


	LIBTOOL=libtool \
	CFLAGS="$INCLUDES" \
	CXXFLAGS="$INCLUDES" \
	LDFLAGS="-L$installdirectory/cups/lib \
		-Wl,-rpath,$installdirectory/cups/lib \
		-L$installdirectory/cndrvcups-common/lib \
		-Wl,-rpath,$installdirectory/cndrvcups-common/lib \
		-L$installdirectory/libxml2/lib \
		-Wl,-rpath,$installdirectory/libxml2/lib \
		-L$installdirectory/gtk\+/lib/ \
		-Wl,-rpath,$installdirectory/gtk\+/lib/ \
		-L$installdirectory/atk/lib/ \
		-Wl,-rpath,$installdirectory/atk/lib/ \
		-L$installdirectory/gdk-pixbuf/lib/ \
		-Wl,-rpath,$installdirectory/gdk-pixbuf/lib/ \
		-L$installdirectory/libglade/lib/ \
		-Wl,-rpath,$installdirectory/libglade/lib/ \
		" \
		./allgen.sh
	find . -type f -print0 | \
		xargs -0 grep -l '$(SHELL) $(top_builddir)/libtool' | \
		xargs sed -i -- 's/$(SHELL) $(top_builddir)\/libtool/libtool/g' 

	find . -type f -print0 | xargs -0 grep -l "/usr/share" | xargs sed -i -- "s|/usr/share/cngplp|$installdirectory/$package_fullname/share/cngplp|g"
	find . -type f -print0 | xargs -0 grep -l "/usr/local" | xargs sed -i -- "s|/usr/local|$installdirectory/$package_fullname|g"

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
	ln -svf "$installdirectory/$package_name/share/cups/model"/* \
		"$installdirectory/cups/share/cups/model/"
	ln -svf "$installdirectory/$package_name/share/cups/model"/* \
		"$installdirectory/cups/share/cups/model/"
	ln -svf "$installdirectory/$package_name/lib/cups/backend"/* \
		"$installdirectory/cups/lib/cups/backend/"
	ln -svf "$installdirectory/$package_name/lib/cups/filter"/* \
		"$installdirectory/cups/lib/cups/filter/"
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




