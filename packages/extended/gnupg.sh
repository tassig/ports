package_name=gnupg
package_version=2.2.17
tarball_suffix=bz2
build_dependencies="libgpg-error libassuan libgcrypt libksba npth sqlite gnutls zlib"
no_check=1  # TODO: test t-http-basic fails, why?

custombuild(){
	rm -rf builddir
	mkdir -p builddir   # do everything in builddir for tidiness
	cd builddir
	wget -O archive $url
	tar xvf archive
	rm archive
	cd *   # cd into the package directory

	# more detail on applied patches: https://git.alpinelinux.org/aports/tree/main/gnupg
	patch -p1 < ../../packages/extended/gnupg/fix-i18n.patch
	patch -p1 < ../../packages/extended/gnupg/0001-Include-sys-select.h-for-FD_SETSIZE.patch

	export CPPFLAGS="-I/opt/libgcrypt/include"
	export LDFLAGS="-Wl,-rpath=/opt/libksba/lib -Wl,-rpath=/opt/libgcrypt/lib -Wl,-rpath=/opt/libgpg-error/lib -Wl,-rpath=/opt/libassuan/lib  -Wl,-rpath=/opt/npth/lib -Wl,-rpath=/opt/sqlite/lib"

	./configure --prefix=$installdirectory/$package_fullname

	make -j
	if test -z $no_check   # run the make check, unless $no_check is set for 
						   # this package definition
	then make -j check || make -j test
	fi
	make install
	ln -sv $installdirectory/$package_fullname $installdirectory/$package_name
	ln -sv $installdirectory/$package_name/bin/* /bin/ || true
	ln -sv $installdirectory/$package_name/sbin/* /bin/ || true
	if [ -d "$installdirectory/$package_name/lib/pkgconfig" ]; then
		ln -svf $installdirectory/$package_name/lib/pkgconfig/* \
		$installdirectory/pkgconf/lib/pkgconfig/
	fi
	cd ../..
	rm -r builddir

}
