package_name=appstream-glib
package_version=0.7.15
tarball_suffix=xz
build_dependencies="glib gdk-pixbuf libarchive libsoup libuuid meson ninja cmake json-glib"
no_check=1 


custombuild(){
	rm -rf builddir
	mkdir -p builddir   # do everything in builddir for tidiness
	cd builddir
	wget -O archive $url
	tar xvf archive
	rm archive
	cd *   # cd into the package directory

	mkdir build
	cd build

	# NOTE: for now we disable many options, out of following reasons:
	#    -Ddep11=false - produce ERROR: Dependency "yaml-0.1" not found
	#    -Dbuild=false  - produce ERROR: Dependency "gdk-3.0" not found
	#    -Drpm=false - produce  ERROR: Dependency "rpm" not found
	#    -Dstemmer=false - produce ERROR: C library 'stemmer' not found
	#    -Dman=false - produce I/O error : Attempt to load network entit http://docbook.sourceforge.net/release/xsl/current/manpages/docbook.xsl
	#    -Dintrospection=false - produce Couldn't find include 'GdkPixbuf-2.0.gir' TODO: we need libgir?
	meson .. --prefix=$installdirectory/$package_fullname -Ddep11=false -Dbuilder=false -Drpm=false -Dstemmer=false -Dman=false -Dintrospection=false

	ninja

	meson install

	ln -sv $installdirectory/$package_fullname $installdirectory/$package_name
	ln -sv $installdirectory/$package_name/bin/* /bin/ || true
	if [ -d "$installdirectory/$package_name/lib/pkgconfig" ]; then
		ln -svf $installdirectory/$package_name/lib/pkgconfig/* \
		$installdirectory/pkgconf/lib/pkgconfig/
	fi
	cd ../../..
	rm -r builddir

}
