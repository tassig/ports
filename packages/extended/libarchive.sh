package_name=libarchive
package_version=3.4.0
tarball_suffix=gz
build_dependencies="zlib libressl"
no_check=1 

# We use custombuild because of --without-xml2, Alpine does it like that, so we don't investigate more
# and because of zlib headers

custombuild(){
	rm -rf builddir
	mkdir -p builddir   # do everything in builddir for tidiness
	cd builddir
	wget -O archive $url
	tar xvf archive
	rm archive
	cd *   # cd into the package directory

	export CPPFLAGS=-I/opt/zlib/include
	./configure --prefix=$installdirectory/$package_fullname --without-xml2

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
