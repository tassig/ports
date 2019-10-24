package_name=polkit
package_version=0.98
tarball_suffix=gz
build_dependencies=expat
no_check=1 

custombuild(){
	rm -rf builddir
	mkdir -p builddir   # do everything in builddir for tidiness
	cd builddir
	wget -O archive $url
	tar xvf archive
	rm archive
	cd *   # cd into the package directory


	# TODO: we still get non fatal error message:
	# Error loading shared library libnettle.so.6: No such file or directory (needed by /opt/glib-2.48.1/lib/gio/modules/libgiognutls.so)
	# Failed to load module: /opt/glib-2.48.1/lib/gio/modules/libgiognutls.so


	export CPPFLAGS="-I/opt/expat/include -I/opt/Linux-PAM/include"
	export LDFLAGS="-L/opt/expat/lib -L/opt/Linux-PAM/lib"
	./configure --prefix=$installdirectory/$package_fullname --disable-man-pages

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
