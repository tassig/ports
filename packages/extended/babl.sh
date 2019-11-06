package_name="babl"
package_version="0.1.18"
tarball_suffix=bz2


custombuild(){
	rm -rf builddir
	mkdir -p builddir   # do everything in builddir for tidiness
	cd builddir
	wget -O archive $package_url
	tar xvf archive
	rm archive
	cd *   # cd into the package directory

	./configure --prefix=/opt/$package_name-$package_version --disable-docs

	ncpu=`cat /proc/cpuinfo | grep processor | wc -l`
	make -j$ncpu
	make install

	ln -sv /opt/$package_name-$package_version /opt/$package_name || true
	ln -sv /$package_name-$package_version/bin/* /bin/ || true

	if [ -d "/opt/$package_name-$package_version/lib/pkgconfig" ]; then
		ln -svf /opt/$package_name-$package_version/lib/pkgconfig/* /opt/pkgconf/lib/pkgconfig
	fi

	cd ../..
	rm -r builddir
}
