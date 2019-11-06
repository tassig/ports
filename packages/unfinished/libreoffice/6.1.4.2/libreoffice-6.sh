package_name=libreoffice
package_version="6.1.4.2"
package_archive="tar.xz"
package_fullname=$package_name-$package_version
url="http://mirrors.tassig.com/libreoffice"
build_dir=/home/builddir # build folder in /home (40GB), this partition will be big enough
TMP=$build_dir/tmp

set -ex

ACTION=$1

# clear all temporary stuff that we applied while running this installation
clean(){
	rm -rf $build_dir
	echo "clear temporary packages..."
	rm -rf /opt/zip*
	rm -rf /opt/bash*
	rm -rf /opt/coreutils*
	rm -rf /opt/tar*
	rm -rf /opt/patch*
	rm -rf /opt/xz*
	rm -rf /opt/Python*
	rm -rf /opt/perl*
	rm -rf /opt/unzip*
	rm -rf /opt/apr*
	rm -rf /opt/aprutil*
	rm -rf /opt/serf*

	echo "revering symlinks..."
	ln -svf /opt/busybox/bin/patch /bin/patch
	ln -svf /opt/busybox/bin/touch /bin/touch
	ln -svf /opt/busybox/bin/md5sum /bin/md5sum
	ln -svf /opt/busybox/bin/tar /bin/tar
	rm -f /opt/gcc-6.1.0/x86_64-longhorn-linux-musl/include/xlocale.h
	rm -rf /usr
	
	echo "deleting libreoffice build dir"
	rm -rf $build_dir

	echo "done"
}

# temporarly install apr, apr-util and ser dependences, these packages are not part of the ports distribution.
# source tarballs are available on mirros.tassig.com and are intended to use only by libreoffice build 
installapachedeps(){
	rm -rf builddir
	mkdir builddir
	cd builddir
	
	ncpu=`cat /proc/cpuinfo | grep processor | wc -l`
	
	# build and install apr-1.6.2
	wget http://mirrors.tassig.com/apr/apr-1.6.2.tar.gz
	tar xvf apr-1.6.2.tar.gz
	rm apr-1.6.2.tar.gz
	cd apr-1.6.2/
	./configure --prefix=/opt/apr-1.6.2
	make -j$ncpu
	make install
	ln -sv /opt/apr-1.6.2 /opt/apr
	ln -sv /opt/apr-1.6.2/bin/* /bin/ || true
	if [ -d "/opt/apr-1.6.2/lib/pkgconfig" ]; then
		ln -svf /opt/apr-1.6.2/lib/pkgconfig/* /opt/pkgconf/lib/pkgconfig
	fi
	cd ../
	
	# build and install apr-util-1.6.0
	wget http://mirrors.tassig.com/apr-util/apr-util-1.6.0.tar.gz
	tar xvf apr-util-1.6.0.tar.gz
	rm apr-util-1.6.0.tar.gz
	cd apr-util-1.6.0/
	./configure --prefix=/opt/apr-util-1.6.0 --with-apr=/opt/apr --with-expat=/opt/expat
	make -j$ncpu CFLAGS="-I/opt/expat/include" LDFLAGS="-L/opt/expat/lib"
	make install
	ln -sv /opt/apr-util-1.6.0 /opt/apr-util
	ln -sv /opt/apr-util-1.6.0/bin/* /bin/ || true
	if [ -d "/opt/apr-util-1.6.0/lib/pkgconfig" ]; then
		ln -svf /opt/apr-util-1.6.0/lib/pkgconfig/* /opt/pkgconf/lib/pkgconfig
	fi
	cd ../
	
	# build and install serf-1.2.1
	wget http://mirrors.tassig.com/serf/serf-1.2.1.tar.bz2
	tar xvf serf-1.2.1.tar.bz2
	rm serf-1.2.1.tar.bz2
	cd serf-1.2.1/
	./configure --prefix=/opt/serf-1.2.1 --with-apr=/opt/apr --with-apr-util=/opt/apr-util --with-openssl=/opt/libressl
	make -j$ncpu CFLAGS="-I/opt/zlib/include" LDFLAGS="-L/opt/zlib/lib -L/opt/libressl/lib"
	make install
	ln -sv /opt/serf-1.2.1 /opt/serf
	ln -sv /opt/serf-1.2.1/bin/* /bin/ || true
	if [ -d "/opt/serf-1.2.1/lib/pkgconfig" ]; then
		ln -svf /opt/serf-1.2.1/lib/pkgconfig/* /opt/pkgconf/lib/pkgconfig
	fi
	
	cd ../../
	rm -rf builddir
}

prepare()
{
	# check existing installation
	if [ -d "/opt/$package_name" ]; then
	    echo "$package_name is already installed"
	    exit 1
	fi

	# libreoffice official info on how to build on Linux systems:
	# see https://wiki.documentfoundation.org/Development/BuildingOnLinux

	# alpine patches for libreoffice build
	# alpine package url: https://git.alpinelinux.org/cgit/aports/tree/community/libreoffice
	# note: we have them available in ./alpine-patches

	# need to install just for the build:
	# - bash, easy to circumvent but we can also install bash for build time, bash is available from ports.git, and then remove it
	# - GNU coreutils, in particular cp, touch and md5sum
	# - GNU tar or BSD tar, (http://ftp.gnu.org/gnu/tar/tar-1.29.tar.xz or 
	# - GNU patch, ( available in ports)
	# - xz  (available at ports)
	# - Python3 (available at ports), reqquired at buidl time
	# - unzip (zip and unzip, available at hutchr)

	# used to correctly apply patches

	export BASE_DIR=$PWD
	
	# TODO: maybe, unzip is already installed, and the build won't work. And clean should not be done for unzip. Same with a few other packages that may exist
	#       /home/builddir may also exist

	# first install hutchr avaliable dependencies
	cd ../../
	sh unzip.sh

	mkdir $build_dir
	cd $build_dir

	# clone ports.git, to build dependences first
	GIT_SSH_COMMAND="ssh -y" sshpass -p "temppassrobotbuilder" git clone ssh://robotbuilder@git.cacaoweb.org/../var/git/ports.git
	cd ports/
	./packageinstall.sh bash
	./packageinstall.sh coreutils
	./packageinstall.sh tar
	./packageinstall.sh patch
	./packageinstall.sh xz
	./packageinstall.sh python3
	./packageinstall.sh perl
	./packageinstall.sh gperf

	if ! [ -d "/opt/serf-1.2.1" ]; then 
		installapachedeps
	fi

	# NOTE: tar and pach will remain busybox symlinked
	# replace some system symlinks, temporarly to run libreoffice build
	ln -svf /opt/patch/bin/patch /bin/patch
	ln -svf /opt/coreutils/bin/touch /bin/touch
	ln -svf /opt/coreutils/bin/md5sum /bin/md5sum
	ln -svf /opt/tar/bin/tar /bin/tar

	# libreoffice openldap depends on nss, we if we don't have it, temporarly install it
	if [ ! -L /opt/nss ]; then
		# this sequence was taken form chromium.sh build
		# we don't want this horrible package to be part of Axiom system, so there is no official installer
		RETPATH=$(pwd)
		mkdir nssbuilddir
		cd nssbuilddir
		wget http://mirrors.tassig.com/nss_nspr/nss-3.27.1-with-nspr-4.13.tar.gz
		tar xf nss-3.27.1-with-nspr-4.13.tar.gz
		cd nss-3.27.1
		mkdir -p dist/public/nss/
		mkdir -p dist/public/dbm
		cd nss
		ln -s /opt/nspr/include/nspr/* ../dist/public/nss/
		ln -s /opt/nspr/include/nspr/* ../dist/public/dbm/
		ln -s /opt/zlib/include/* ../dist/public/nss/
		sed -i 's/$(OS_PTHREAD) -ldl -lc/$(OS_PTHREAD) -ldl -lc -lnspr4 -L\/opt\/nspr\/lib -Wl,-rpath,\/opt\/nspr\/lib -Wl,-rpath,\/opt\/nss\/lib/' coreconf/Linux.mk

		make USE_64=1
		make USE_64=1 install

		cd ..
		
		# nss bins and libs will be installed in ./dist as symlinks, so we manually copying it in using -L option
		mkdir -p /opt/nss-3.27.1/include/nss
		cp -rL ./dist/Linux*_cc_glibc_PTH_64_DBG.OBJ/* /opt/nss-3.27.1/
		cp -rL ./dist/public/nss/* /opt/nss-3.27.1/include/nss/ # libreoffice will need nss headers
		# we have to create pkgconfig file manually
		cat > /opt/pkgconf/lib/pkgconfig/nss.pc <<EOF
prefix=/opt/nss-3.27.1
exec_prefix=\${prefix}
libdir=\${exec_prefix}/lib
includedir=\${prefix}/include/nss

Name: NSS
Description: The Netscape Portable Runtime
Version: 3.27.1
Requires: nspr
Libs: -L\${exec_prefix}/lib -lssl3 -lsmime3 -lnss3 -lnssutil3
Cflags: -I\${prefix}/include/nss
EOF
		
		ln -sv /opt/nss-3.27.1 /opt/nss
		cd "$RETPATH"
	fi

	# return to build folder, download libreoffice sources and unpack
	cd ../
	wget $url/$package_name-$package_version.$package_archive
	cd $build_dir
	tar xf $package_name-$package_version.$package_archive

	# apply alpine patches
	cd $package_name-$package_version
	patch -p1 < $BASE_DIR/alpine-patches/disable-liborcus-unittest.patch
	patch -p1 < $BASE_DIR/alpine-patches/fix-execinfo.patch
	patch -p1 < $BASE_DIR/alpine-patches/fix-includes.patch
	patch -p1 < $BASE_DIR/alpine-patches/linux-musl.patch
	patch -p1 < $BASE_DIR/alpine-patches/musl-libintl.patch
	patch -p1 < $BASE_DIR/alpine-patches/musl-stacksize.patch

	# apply axiom patches
	patch -p1 < $BASE_DIR/axiom-patches/fix-visibility.patch # without this, liblocaledata_en will contain only local symbols. This will fail the build

	# apply some hacks before we build, to prevent build failure..
	# TODO: find the reason we need to perform it, it is relatred to solenv/bin/packimages.pl and the fact that theme list is given with \ separator
	#       for oxugen only theme, it is given as \oxygen, where perl script will remove trailaing \, but inlstall procedure will complain later on (see fixes before make install)
	mkdir -p icon-themes/export
	cp -r icon-themes/elementary/* icon-themes/export # prevent build failure build process will expect this folder with contents theme we are building with
}

configure()
{
	cd $build_dir/$package_fullname
	# autogen.sh will propagate musl patch changes form configure.ac to configure
	NOCONFIGURE=1 ./autogen.sh > /dev/null

	# configure and build

	# explanations:
	# CFLAGS  - broken support xorg and zlib, can't discover proper includes
	# CXXFLAGS - same
	# LDFLAGS -force rpath for all shared libraries, libtool won't find them automatically, note: we also need to do it for libstdc++, which is strange
	# --prefix=/opt/libreoffice, standard Axiom install path
	# --disable-dbus - won't use dbus, Axiom won't support it
	# --disable-cups - won't support apple open source priter protocols
	# --without-java - don't use JAVA
	# --without-doxygen - don't use doxygen
	# --with-system-zlib=no - build and link against internal zlib
	# --without-krb5 - not sure
	# --without-gssapi - don't use IETF standard for strong encrypted authentification
	# --disable-gtk3 - force GTK2
	# --disable-gstreamer-1-0 - don't use gstreamer
	# --disable-neon - don't use HTTP and WebDAV library
	# --with-gnu-cp=/opt/coreutils/bin/cp - force GNU coreutils cp instead of busybox
	# --disable-firebird-sdbc - disable Firebird database support
	# --x-includes=/opt/xorg/include - explicit path to X includes, but seems it does not propagate through whole build, so we use additional flags
	# --x-libraries=/opt/xorg/lib - explicit path to X libraries, but seems it does not propagate through whole build, so we use additional flags
	# --enable-python=no, disable runtime Python support, still we need Python3 for build process
	# --with-system-serf - serf configure is broken and unable to detect apr-util path, we install apr, apr-util and serf as external packages, and clean them at the end
	# --with-theme=oxygen, we only support GTK2 themes, oxygen and adwaita in particular, and libreoffice supports oxygen too
	# --disable-cve-tests - sometimes watchdog's thread kills test and this causes build to fail
	# --with-lang="en-US fr ru ja" - build ALL available UI languages

	#CFLAGS="-I/opt/xorg/include -I/opt/zlib/include" CXXFLAGS="-I/opt/xorg/include" LDFLAGS="-L/opt/xorg/lib -Wl,-rpath=/opt/xorg/lib -L/opt/cairo/lib -Wl,-rpath=/opt/cairo/lib -L/opt/glib/lib -Wl,-rpath=/opt/glib/lib -L/opt/fontconfig/lib -Wl,-rpath=/opt/fontconfig/lib -L/opt/freetype/lib -Wl,-rpath=/opt/freetype/lib -L/opt/gcc-6.1.0/lib64 -Wl,-rpath=/opt/gcc-6.1.0/lib64 -L/opt/libxslt/lib/ -Wl,-rpath=/opt/libxslt/lib/ -L/opt/gdk-pixbuf/lib/ -Wl,-rpath=/opt/gdk-pixbuf/lib/ -L/opt/atk/lib/ -Wl,-rpath=/opt/atk/lib/ -L/opt/pango/lib/ -Wl,-rpath=/opt/pango/lib/ -L/opt/libxml2/lib/ -Wl,-rpath=/opt/libxml2/lib" ./configure --prefix=/opt/libreoffice --disable-dbus --disable-cups --without-java --without-doxygen --with-system-zlib=no --without-krb5 --without-gssapi --disable-gtk3  --disable-gstreamer-1-0 --disable-neon --with-gnu-cp=/opt/coreutils/bin/cp --disable-firebird-sdbc --x-includes=/opt/xorg/include --x-libraries=/opt/xorg/lib --enable-python=no --with-system-serf --with-theme=oxygen --with-parallelism=4 --with-system-nss
	CFLAGS="-I/opt/xorg/include -I/opt/zlib/include" CXXFLAGS="-I/opt/xorg/include -I/opt/zlib/include" \
		LDFLAGS="-L/opt/xorg/lib -Wl,-rpath=/opt/xorg/lib \
			-L/opt/cairo/lib -Wl,-rpath=/opt/cairo/lib \
			-L/opt/glib/lib -Wl,-rpath=/opt/glib/lib \
			-L/opt/fontconfig/lib -Wl,-rpath=/opt/fontconfig/lib \
			-L/opt/freetype/lib -Wl,-rpath=/opt/freetype/lib \
			-L/opt/gcc-6.1.0/lib64 -Wl,-rpath=/opt/gcc-6.1.0/lib64 \
			-L/opt/libxslt/lib/ -Wl,-rpath=/opt/libxslt/lib/ \
			-L/opt/gdk-pixbuf/lib/ -Wl,-rpath=/opt/gdk-pixbuf/lib/ \
			-L/opt/atk/lib/ -Wl,-rpath=/opt/atk/lib/ \
			-L/opt/pango/lib/ -Wl,-rpath=/opt/pango/lib/ \
			-L/opt/libxml2/lib/ -Wl,-rpath=/opt/libxml2/lib \
			-L/opt/nss/lib -Wl,-rpath,/opt/nss/lib -L/opt/nspr/lib -Wl,-rpath,/opt/nspr/lib \
			-L/opt/zlib/lib -Wl,-rpath,/opt/zlib/lib \
			-Wl,-rpath,/opt/curl/lib \
			-Wl,-rpath,/opt/gtk+/lib" \
		./configure \
			--prefix=/opt/$package_fullname \
			--disable-dbus \
			--disable-cups \
			--without-java \
			--without-doxygen \
			--with-system-zlib \
			--without-krb5 \
			--without-gssapi \
			--disable-gtk3 \
			--disable-gstreamer-1-0 \
			--disable-neon \
			--with-gnu-cp=/opt/coreutils/bin/cp \
			--disable-firebird-sdbc \
			--x-includes=/opt/xorg/include \
			--x-libraries=/opt/xorg/lib \
			--enable-python=no \
			--with-system-serf \
			--with-theme=elementary \
			--with-parallelism=4 \
			--with-system-nss \
			--with-system-curl \
			--disable-postgresql-sdbc \
			--enable-release-build \
			--enable-split-app-modules \
			--disable-cve-tests \
			--with-lang="en-US fr ru ja"

	# More hacks:
	# 1. Makefile will prevent root build, replace the line, to remove check-if-root
	sed -i '/bootstrap: check-if-root compilerplugins/c\bootstrap: compilerplugins' Makefile

	# 2. instead of patching scripts around, temporarly create required symlinks
	mkdir -p /usr/bin
	ln -svf /bin/env /usr/bin/env
	ln -svf /bin/bash /usr/bin/bash

	# 3. musl won't include xlocale.h, we need to provide a symlink
	# TODO: this may be the reason of build break at one point, complaining about 
	ln -svf /opt/gcc-6.1.0/x86_64-longhorn-linux-musl/include/locale.h /opt/gcc-6.1.0/x86_64-longhorn-linux-musl/include/xlocale.h

	# 4. redirect build system to download external tarballs form Axiom mirror location
	# sed -i "s/dev-www.libreoffice.org/mirrors.tassig.com\/libreoffice\/tarballs/g" Makefile.fetch

	# now we need to point gmake to downloaded translations
	ln -svf ./src/libreoffice-translations-$package_version/translations ./
}

build(){
	cd $build_dir/$package_fullname
	mkdir -p $TMP
	export CPPFLAGS="-I/opt/nss/include -I/opt/nspr/include"
	export LDFLAGS="-L/opt/nss/lib -L/opt/nspr/lib"
	
	# explanations:
	# CFLAGS.EXTRA - glew external package build won't find X includes, and won't get -fPIC flag internally, so we need to supply it via EXTRA flags
	# LDFLAGS.EXTRA - glew external package build won't find X libs, we need to supply it explicitely via EXTRA flags
	# APRUTIL_LIBS - apr and apr-util external packages build won't find expat libs, we need to supply this path too...
	# NOTE: for more verbose build use GMAKE_OPTIONS='VERBOSE 1'
	TMPDIR=$TMP make CFLAGS.EXTRA="-I/opt/xorg/include -fPIC" LDFLAGS.EXTRA="-L/opt/xorg/lib" APRUTIL_LIBS="-L/opt/expat/lib"
}

# the install procedure is just for testing and packaging, libreoffice being distributed via hutchr
install(){
	# libreoffice will be distributed via hutchr anyway
	cd $build_dir/$package_fullname/instdir
	rm -rf /opt/$package_fullname
	mkdir /opt/$package_fullname

	cp -R * /opt/$package_fullname/

	# make install is broken: there will be errors on File menu, almost no
	# icons and it will hang randomly
	#TMPDIR=$TMP make install
	# TODO: that's not good, install should be working and do useful actions, maybe necessary ones
	
	# create symlinks
	ln -sv $package_fullname /opt/$package_name
	ln -sv /opt/$package_name/program/soffice /bin
	ln -sv /opt/$package_name/program/swriter /bin
	ln -sv /opt/$package_name/program/scalc /bin
	ln -sv /opt/$package_name/program/simpress /bin
	ln -sv /opt/$package_name/program/sdraw /bin
	ln -sv /opt/$package_name/program/smath /bin
	ln -sv /opt/$package_name/program/sbase /bin

        # the following rewrites the *.desktop files so they can run libreoffice via hutchr, because we are not running make ins
        sed -i 's/${UNIXBASISROOTNAME}/hutchr libreoffice/g' /opt/$package_name/share/xdg/*.desktop
        sed -i 's/${PRODUCTNAME}/LibreOffice/g' /opt/$package_name/share/xdg/*.desktop
        sed -i 's/${PRODUCTVERSION}/ /g' /opt/$package_name/share/xdg/*.desktop     

}

case $ACTION in
	install)
		install
	;;
	clean)
		clean
	;;
	prepare)
		prepare
		configure 
	;;
	configure)
		configure
	;;
	build)
		build
	;;
	version)
		echo $package_version
	;;
	*)
		prepare
		configure
		build
		install
		clean
	;;
esac


