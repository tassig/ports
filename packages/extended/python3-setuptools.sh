
package_name=python3-setuptools
package_version=41.5.0
tarball_suffix=gz
build_dependencies=
no_check=1


function custombuild(){
	builddir="builddir-$package_fullname"  # build directory is "builddir" followed by the name of the package, which allows multiple builds of different software in parallel
	rm -rf $builddir
	mkdir -p $builddir   # do everything in builddir for tidiness
	cd $builddir
	wget -O archive $url
	tar xvf archive
	rm archive
	cd *   # cd into the package directory

  python3 ./bootstrap.py
  python3 ./setup.py install

	ln -snv $installdirectory/$package_fullname $installdirectory/$package_name || true
	ln -sv $installdirectory/$package_name/bin/* $bindirectory || true   # don't crash if the links are already there
	if [ -d "$installdirectory/$package_fullname/lib/pkgconfig" ]; then
		ln -svf $installdirectory/$package_fullname/lib/pkgconfig/* $installdirectory/pkgconf/lib/pkgconfig/   # symlink pkg-config files
	fi
	# NOTE: .m4 files should probably be installed as well by default, but i have no strong opinion on it, so for now we leave this to the postinstall() function
	cd ../..
	rm -r $builddir
}
