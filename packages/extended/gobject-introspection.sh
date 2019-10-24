package_name=gobject-introspection
package_version=1.46.0
tarball_suffix=xz
build_dependencies=
no_check=1 

# We use custombuild because we have to patch for wrong python path presumption

custombuild(){
	rm -rf builddir
	mkdir -p builddir   # do everything in builddir for tidiness
	cd builddir
	wget -O archive $url
	tar xvf archive
	rm archive
	cd *   # cd into the package directory

	./configure --prefix=$installdirectory/$package_fullname 

	# patch template file, not to use /usr while retrieving python
	# file g-ir-scanner will be created during make, and will wrongly presume /usr/bin/env python, while we need /bin/python
	sed -i 's|/usr/bin/env @PYTHON@|@PYTHON@|g' tools/g-ir-tool-template.in

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
