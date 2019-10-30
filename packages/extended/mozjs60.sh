# TODO: not fully workig yet

package_name=mozjs60
package_version=
tarball_suffix=
build_dependencies="zlib python2 perl sed autoconf2-13"  # 
no_check=1 

# We use custombuild because we have to patch for wrong python path presumption

custombuild(){
	rm -rf builddir
	mkdir -p builddir   # do everything in builddir for tidiness
	cd builddir

	# mozjs is firefox js runtime, we need full firefox sources
	wget -O archive http://mirrors.tassig.com/mozjs/firefox-60.8.0esr.source.tar.xz
	tar xvf archive
	rm archive
	cd *   # cd into the package directory

	cd js/src

	# apply alpine patches
	patch -p1 < $SRC_DIR/packages/extended/mozjs60/0001-silence-sandbox-violations.patch
	patch -p1 < $SRC_DIR/packages/extended/mozjs60/big-endian.patch
	patch -p1 < $SRC_DIR/packages/extended/mozjs60/fix-musl-build.patch
	patch -p1 < $SRC_DIR/packages/extended/mozjs60/fix-soname-lib.patch

	export LDFLAGS="$LDFLAGS -Wl,-z,stack-size=1048576"
	touch configure  # we need this, otherwise make will complain, TODO: why?

	# NOTE: we don't care about --prefix, we will delete it, and use make insrtall with DEST_DIR instead
	PYTHON=/bin/python ./configure --prefix=$installdirectory/mozjs-tmp --with-system-zlib=/opt/zlib --with-intl-api --enable-shared-js --disable-optimize --disable-jemalloc --enable-pie

	make

	# instead of make check, we use this
	# dist/bin/jsapi-tests

	make install

	make DESTDIR="$installdirectory/$package_fullname" install
	rm -r $installdirectory/mozjs-tmp

	cd ../../../
	rm -r builddir
}
