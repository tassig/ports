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
	cp -f unrar /bin

	cd ../../
	rm -r builddir
}
