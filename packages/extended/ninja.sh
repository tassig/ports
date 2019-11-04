package_name=ninja
package_version=1.8.2
tarball_suffix=gz
build_dependencies="python2"

custombuild(){
	rm -rf builddir
	mkdir -p builddir   # do everything in builddir for tidiness
	cd builddir
	wget -O archive $url
	tar xvf archive
	rm archive
	cd *   # cd into the package directory

	python configure.py --bootstrap

	# we have to copy ninja executable somwhere, and make it availabe in the path
	# mimic classic install procedure
	mkdir -p $installdirectory/$package_fullname/bin
	cp ninja $installdirectory/$package_fullname/bin/

	ln -sv $installdirectory/$package_fullname $installdirectory/$package_name
	ln -sv $installdirectory/$package_name/bin/* $bindirectory || true

	cd ../..
	rm -r builddir
}
