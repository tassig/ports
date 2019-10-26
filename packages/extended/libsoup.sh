package_name=libsoup
package_version=2.51.92
tarball_suffix=xz
build_dependencies="sqlite libxml2"
no_check=1 

custombuild(){
	rm -rf builddir
	mkdir -p builddir   # do everything in builddir for tidiness
	cd builddir
	wget -O archive $url
	tar xvf archive
	rm archive
	cd *   # cd into the package directory

	LDFLAGS="-Wl,-rpath,/opt/glib/lib" ./configure --prefix=$installdirectory/$package_fullname --enable-vala=no --disable-tls-check

	# workarounf wrong python presumption
	sed -i 's|/usr/bin/env python|/bin/python|g' libsoup/tld-parser.py

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
