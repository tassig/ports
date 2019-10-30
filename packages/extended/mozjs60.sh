# TODO: not fully workig yet

package_name=mozjs60
package_version=
tarball_suffix=
build_dependencies="zlib python2 perl"  # depends on autoconf-2.13, we do it internally
no_check=1 

# We use custombuild because we have to patch for wrong python path presumption

custombuild(){
	SRC_DIR=$(pwd)
	rm -rf builddir
	mkdir -p builddir   # do everything in builddir for tidiness
	cd builddir

	# install autoconf-2.13, temporarly, then we'll delete it
	wget http://mirrors.tassig.com/autoconf/autoconf-2.13.tar.gz
	tar xf autoconf-2.13.tar.gz
	cd autoconf-2.13
	./configure --prefix=/opt/autoconf-2.13-temp
	make
	make install
	ln -svf /opt/autoconf-2.13-temp/bin/autoconf /bin/autoconf-2.13  # this is what js configure searches for
	cd ../

	# mozjs is firefox js runtime, we need full firefox sources
	wget -O archive http://mirrors.tassig.com/mozjs/firefox-60.8.0esr.source.tar.xz
	tar xvf archive
	rm archive
	cd firefox-60.8.0

	# apply alpine patches in root folder
	patch -p1 < $SRC_DIR/packages/extended/mozjs60/0001-silence-sandbox-violations.patch
	patch -p1 < $SRC_DIR/packages/extended/mozjs60/big-endian.patch
	patch -p1 < $SRC_DIR/packages/extended/mozjs60/fix-musl-build.patch
	patch -p1 < $SRC_DIR/packages/extended/mozjs60/fix-soname-lib.patch

	cd js/src
	export LDFLAGS="$LDFLAGS -Wl,-z,stack-size=1048576"
	export SHELL=/bin/sh
	touch configure  # we need this, otherwise make will complain, TODO: why?

	# NOTE: we don't care about --prefix, we will delete it, and use make insrtall with DEST_DIR instead
	PYTHON=/bin/python ./configure --prefix=$installdirectory/mozjs-tmp --with-system-zlib=/opt/zlib --with-intl-api --enable-shared-js --disable-optimize --disable-jemalloc --enable-pie

	make
	rm /bin/autoconf-2.13
	exit 0

	# instead of make check, we use this
	# dist/bin/jsapi-tests

	make DESTDIR="$installdirectory/$package_fullname" install
	rm -r $installdirectory/mozjs-tmp

	rm /bin/autoconf-2.13

	cd ../../../
	rm -r builddir
}
