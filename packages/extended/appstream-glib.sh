package_name=appstream-glib
package_version=0.7.16
tarball_suffix=xz
build_dependencies="glib gdk-pixbuf libarchive libsoup"
no_check=1 

# We use old version 0.1.7, the last one that builds with gtk2, all newer versions require gtk3
# TODO: no, i tried latest versions and disabled a few things in meson_options.txt , and it doesn't require gtk3
# TODO: error during linking, needs -PIC library from e2fsprogs

# We use custom build just because --enable-introspection=no, with default build we get error:
# Couldn't find include 'GdkPixbuf-2.0.gir'\
# TODO: solution is to add libgirepository1.0, so we can have clean default build

custombuild(){
	rm -rf builddir
	mkdir -p builddir   # do everything in builddir for tidiness
	cd builddir
	wget -O archive $url
	tar xvf archive
	rm archive
	cd *   # cd into the package directory

	./configure --prefix=$installdirectory/$package_fullname --enable-introspection=no

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
