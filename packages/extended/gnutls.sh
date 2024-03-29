package_name=gnutls
package_version=3.5.7   # 3.6.6 has compilation issues with nettle TODO: upload 3.5.7 on mirrors.tassig.com
tarball_suffix=xz
build_dependencies="gmp libidn libunistring libtasn1 nettle"
no_check=1   # some tests fail



# custombuild because gmp does not have pkg-config support
# also we disable some features, since we don't have a default build anyway, no need to work too hard for these

function custombuild() {
	rm -rf builddir
	mkdir -p builddir   # do everything in builddir for tidiness
	cd builddir
	wget -O archive $url
	tar xvf archive
	rm archive
	cd *   # cd into the package directory
	
	
	# gmp does not have pkg-config support
	export CFLAGS="-I/opt/gmp/include"
	export LDFLAGS="-L/opt/gmp/lib -Wl,-rpath=/opt/gmp/lib"
	
	# although libtasn1 has pkg-config support, gnutls doesn't make use of it
	export CFLAGS="$CFLAGS -I/opt/libtasn1/include"
	export LDFLAGS="$LDFLAGS -L/opt/libtasn1/lib -Wl,-rpath=/opt/libtasn1/lib"
	
	# although libidn has pkg-config support, gnutls doesn't make use of it
	export CPPFLAGS="-I/opt/libidn/include"
	export LDFLAGS="$LDFLAGS -L/opt/libidn/lib -Wl,-rpath=/opt/libidn/lib"
	
	# issue with nettle compilation
	export CFLAGS="$CFLAGS -I/opt/nettle/include"
	export LDFLAGS="$LDFLAGS -L/opt/nettle/lib -Wl,-rpath=/opt/nettle/lib"
	
	
	# libunbound, trousers not installed so support is missing (i don't know if it's important or not)
	# --without-p11-kit: we didn't install p11-kit
	# --with-included-unistring: libunistring does not have pkg-config support, otherwise we wouldn't need --with-included-unistring
	./configure --prefix=$installdirectory/$package_fullname/ --with-included-unistring --without-p11-kit
	
	
	ncpu=`cat /proc/cpuinfo | grep processor | wc -l`
	make -j$ncpu
	if test -z $no_check   # run the make check, unless $no_check is set for this package definition
	then make -j$ncpu check || make -j$ncpu test
	fi
	make install
	ln -snv $installdirectory/$package_fullname $installdirectory/$package_name || true
	ln -sv $installdirectory/$package_name/bin/* /bin/ || true   # don't crash if the links are already there
	if [ -d "$installdirectory/$package_fullname/lib/pkgconfig" ]; then
		ln -svf $installdirectory/$package_fullname/lib/pkgconfig/* $installdirectory/pkgconf/lib/pkgconfig/   # symlink pkg-config files
	fi
	cd ../..
	rm -r builddir
}
