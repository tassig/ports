package_name=bubblewrap
package_version=0.3.3
tarball_suffix=xz
build_dependencies="autoconf automake libcap"
no_check=1 

custombuild(){
	SRC_DIR=$(pwd)
	rm -rf builddir
	mkdir -p builddir   # do everything in builddir for tidiness
	cd builddir
	wget -O archive $url
	tar xvf archive
	rm archive
	cd *   # cd into the package directory

	NOCONFIGURE=1 ./autogen.sh

	# Apply alpine patches
	patch -p1 < $SRC_DIR/packages/extended/bubblewrap/musl-fixes.patch
	patch < $SRC_DIR/packages/extended/bubblewrap/realpath-workaround.patch

	CFLAGS="-I/opt/libcap/include" LDFLAGS="-L/opt/libcap/lib -Wl,-rpath=/opt/libcap/lib" ./configure --prefix=/opt/$package_fullname --with-priv-mode=setuid --enable-man=no

	make -j
	if test -z $no_check   # run the make check, unless $no_check is set for 
						   # this package definition
	then make -j check || make -j test
	fi

	make install

	ln -sv $installdirectory/$package_fullname $installdirectory/$package_name
	ln -sv $installdirectory/$package_name/bin/* /bin/ || true
	if [ -d "$installdirectory/$package_name/lib/pkgconfig" ]; then
		ln -svf $installdirectory/$package_name/lib/pkgconfig/* \
		$installdirectory/pkgconf/lib/pkgconfig/
	fi
	cd ../..
	rm -r builddir

}
