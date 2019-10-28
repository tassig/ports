package_name=Python
package_version=3.5.7
tarball_suffix=xz
build_dependencies=
no_check=1   # don't hesitate to fix it

function custombuild(){
	builddir="builddir-$package_fullname"  # build directory is "builddir" followed by the name of the package, which allows multiple builds of different software in parallel
	rm -rf $builddir
	mkdir -p $builddir   # do everything in builddir for tidiness
	cd $builddir
	wget -O archive $url
	tar xvf archive
	rm archive
	cd *   # cd into the package directory
	CFLAGS="-I/opt/zlib/include" \
        LDFLAGS="-L/opt/zlib/lib -Wl,-rpath,/opt/zlib/lib" \
        ./configure --prefix=$installdirectory/$package_fullname/
	ncpu=`cat /proc/cpuinfo | grep processor | wc -l`
	make -j$ncpu
	if test -z $no_check   # run the make check, unless $no_check is set for this package definition
	then make -j$ncpu check || make -j$ncpu test
	fi
	make install
	ln -snv $installdirectory/$package_fullname $installdirectory/$package_name || true
	ln -sv $installdirectory/$package_name/bin/* $bindirectory || true   # don't crash if the links are already there
	if [ -d "$installdirectory/$package_fullname/lib/pkgconfig" ]; then
		ln -svf $installdirectory/$package_fullname/lib/pkgconfig/* $installdirectory/pkgconf/lib/pkgconfig/   # symlink pkg-config files
	fi
	# NOTE: .m4 files should probably be installed as well by default, but i have no strong opinion on it, so for now we leave this to the postinstall() function
	cd ../..
	rm -r $builddir
}
postinstall() {
	# we add the symlinks manually
	# Python 3 has binaries names that do not conflict with other versions of Python, so we can symlink them directly. This is necessary because Python 3 may not have the symlink /opt/Python, so the default build will not put its binaries into /bin
	ln -sf $installdirectory/$package_fullname/bin/* $bindirectory || true
}

# NOTE: python3 does not create a binary named "python", instead it is named "python3"
