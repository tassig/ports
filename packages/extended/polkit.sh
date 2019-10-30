package_name=polkit
package_version=0.116
tarball_suffix=gz
build_dependencies="glib intltool Linux-PAM gobject-introspection expat mozjs"
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

	# Apply alpine patch
	patch -p1 < $SRC_DIR/packages/extended/polkit/make-innetgr-optional.patch

	# Apply patch to fix issue with perl script (src/polkitbackend/toarray.pl), which fails to update cpp file
	# TODO: although it compiles, not sure if this is proper fix, so fix perl script instead
	sed -i 's:/usr/bin/perl:/bin/perl:' src/polkitbackend/toarray.pl
	#sed -i 's:init_js:"init.js":g' src/polkitbackend/polkitbackendjsauthority.cpp

	export CPPFLAGS="-I/opt/expat/include -I/opt/Linux-PAM/include"
	export LDFLAGS="-L/opt/expat/lib -L/opt/Linux-PAM/lib"

	# TODO: IMPORTANT: check if polkit depend on mozjs in runtime, it's 1GB of full installation

	# TODO: resolve issue with g-ir-scanner, we had to use --enable-introspection=no temporarly
	./configure --prefix=$installdirectory/$package_fullname --disable-libelogind --enable-introspection=no --disable-man-pages

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
