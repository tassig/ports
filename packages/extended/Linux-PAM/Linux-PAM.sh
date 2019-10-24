package_name=Linux-PAM
package_version=1.3.1
tarball_suffix=xz
build_dependencies="bison flex autoconf automake libtool"
no_check=1 

custombuild(){
	rm -rf builddir
	mkdir -p builddir   # do everything in builddir for tidiness
	cd builddir
	wget -O archive $url
	tar xvf archive
	rm archive
	cd *   # cd into the package directory

	# more detail on applied patches: https://git.alpinelinux.org/aports/tree/main/linux-pam
	sed -e 's/pam_rhosts//g' -i modules/Makefile.am
	patch -p1 < ../../packages/extended/$package_name/fix-compat.patch
	patch -p1 < ../../packages/extended/$package_name/libpam-fix-build-with-eglibc-2.16.patch
	patch -p1 < ../../packages/extended/$package_name/musl-fix-pam_exec.patch

	export export ac_cv_search_crypt=no
	autoreconf -fiv
	./configure --prefix=$installdirectory/$package_fullname --disable-nls --disable-db

	make -j
	if test -z $no_check   # run the make check, unless $no_check is set for 
						   # this package definition
	then make -j check || make -j test
	fi

	make install

	# NOTE: add the end, we also have to copy the directory ./libpam/include/security, which was not installed in the destination directory, but is needed by programs linking against pam. I don't know what's the reason.
	cp -f ./libpam/include/security/* $installdirectory/$package_fullname/include

	ln -sv $installdirectory/$package_fullname $installdirectory/$package_name
	ln -sv $installdirectory/$package_name/bin/* /bin/ || true
	if [ -d "$installdirectory/$package_name/lib/pkgconfig" ]; then
		ln -svf $installdirectory/$package_name/lib/pkgconfig/* \
		$installdirectory/pkgconf/lib/pkgconfig/
	fi
	cd ../..
	rm -r builddir

}
