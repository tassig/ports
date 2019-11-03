package_name=glib-networking
package_version=2.48.2
tarball_suffix=xz
build_dependencies="glib gnutls intltool gsettings-desktop-schemas"
no_check=1


# NOTE: the modules are installed in /opt/glib/
# NOTE: some issue with nettle rpath missing at runtime, which is a bit abnormal because nettle should be a dependency of gnutls, not a direct dependency of this glib module.

custombuild(){
	rm -rf builddir
	mkdir -p builddir   # do everything in builddir for tidiness
	cd builddir
	wget -O archive $url
	tar xvf archive
	rm archive
	cd *   # cd into the package directory

	export LDFLAGS="-Wl,-rpath=/opt/glib/lib -Wl,-rpath=/opt/nettle/lib"
	./configure --prefix=$installdirectory/$package_fullname 

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
