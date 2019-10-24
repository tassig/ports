package_name=gcab
package_version=0.7
tarball_suffix=xz
build_dependencies=zlib
no_check=1 

custombuild(){
	rm -rf builddir
	mkdir -p builddir   # do everything in builddir for tidiness
	cd builddir
	wget -O archive $url
	tar xvf archive
	rm archive
	cd *   # cd into the package directory

	export LD_LIBRARY_PATH=/opt/glib/lib  # otherwise configure will complain of being unable to link glib test program
	export CFLAGS=-I/opt/zlib/include
	export LDLAGS=-I/opt/zlib/lib
	./configure --prefix=$installdirectory/$package_fullname

	# NOTE: we will get non fatal error with libnettle.so.6 missing

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
