package_name=unrar
package_version=5.5.8
tarball_suffix=gz
build_dependencies=
no_check=1

custombuild(){

	rm -rf builddir
	mkdir -p builddir
	cd builddir
	wget -O archive $url
	tar xvf archive
	rm archive
	cd *

	make
	make install DESTDIR=/opt/unrar-5.5.8/

	ln -sv $installdirectory/$package_fullname $installdirectory/$package_name
	ln -sv $installdirectory/$package_name/bin/* /bin/ || true

	cd ../../
	rm -r builddir
}
