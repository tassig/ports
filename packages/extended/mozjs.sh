package_name=mozjs
package_version=60.8.0
tarball_suffix=
build_dependencies="zlib python2 perl"  # depends on autoconf-2.13, we do it internally
no_check=1 

# NOTE: full installation takes 1GB of space, static lib itself takes 660MB, we may not need it

custombuild(){
	SRC_DIR=$(pwd)
	rm -rf builddir
	mkdir -p builddir
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
	wget -O archive http://mirrors.tassig.com/mozjs/firefox-${package_version}esr.source.tar.xz
	tar xvf archive
	rm archive
	cd firefox-$package_version

	# apply alpine patches in root folder
	patch -p1 < $SRC_DIR/packages/extended/mozjs/0001-silence-sandbox-violations.patch
	patch -p1 < $SRC_DIR/packages/extended/mozjs/big-endian.patch
	patch -p1 < $SRC_DIR/packages/extended/mozjs/fix-musl-build.patch
	patch -p1 < $SRC_DIR/packages/extended/mozjs/fix-soname-lib.patch

	cd js/src
	export LDFLAGS="$LDFLAGS -Wl,-z,stack-size=1048576"
	export SHELL=/bin/sh
	touch configure  # we need this, otherwise make will complain

	PYTHON=/bin/python ./configure --prefix=$installdirectory/$package_fullname --with-system-zlib=/opt/zlib --with-intl-api --enable-shared-js --disable-optimize --disable-jemalloc --enable-pie

	make
	# dist/bin/jsapi-tests  # use this instead of make check
	make install

	ln -sv $installdirectory/$package_fullname $installdirectory/$package_name
	ln -sv $installdirectory/$package_name/bin/* /bin/ || true
	if [ -d "$installdirectory/$package_name/lib/pkgconfig" ]; then
		ln -svf $installdirectory/$package_name/lib/pkgconfig/* \
		$installdirectory/pkgconf/lib/pkgconfig/
	fi

	# remove autoconf-2.13
	rm -rf /opt/autoconf-2.13-temp
	rm -f /bin/autoconf-2.13

	cd ../../../../
	rm -r builddir
}
