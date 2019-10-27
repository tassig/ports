package_name=gpgme
package_version=1.13.1
tarball_suffix=bz2
build_dependencies=gnupg/gnupg
no_check=1 

custombuild(){
	rm -rf builddir
	mkdir -p builddir   # do everything in builddir for tidiness
	cd builddir
	wget -O archive $url
	tar xvf archive
	rm archive
	cd *   # cd into the package directory

	# NOTE: this one is quite weird: you need to run: gpg-agent --server , then you can do the build (some tests are run)
	#       so i'm using --disable arguments to configure
	./configure --prefix=$installdirectory/$package_fullname --disable-gpg-test --disable-gpgconf-test

	# NOTE: we have one warrning after configure:
	# Mismatches between the target platform and the to
    # be used libraries have been been detected for: libgpg-error

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
