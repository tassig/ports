package_name=dconf
package_version=0.24.0
tarball_suffix=xz
build_dependencies="dbus glib gtk+2 libxml2"
no_check=1 

# We use custombuild because we don't have dbus pkgconf in /opt/pkgconf/lib/pkgconfig/ TODO:why, it should be there, we have dbus in axiom
# and because there is problem with building man, so we have to disable it

custombuild(){
	rm -rf builddir
	mkdir -p builddir   # do everything in builddir for tidiness
	cd builddir
	wget -O archive $url
	tar xvf archive
	rm archive
	cd *   # cd into the package directory

	PKG_CONFIG_PATH=/opt/dbus/lib/pkgconfig ./configure --prefix=$installdirectory/$package_fullname --enable-man=no

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
