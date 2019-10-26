package_name=vala-bootstrap
package_version=26102019
tarball_suffix=gz
build_dependencies=""
no_check=1 # TODO: ./vala-bootstrap/tests/testrunner.sh contains #!/usr/bin/env bash

function custombuild(){
	builddir="builddir-$package_fullname"  # build directory is "builddir" followed by the name of the package, which allows multiple builds of different software in parallel
	rm -rf $builddir
	mkdir -p $builddir   # do everything in builddir for tidiness
	cd $builddir
	wget -O archive $url
	tar xvf archive
	rm archive
	cd *   # cd into the package directory
	./configure --prefix=$installdirectory/$package_fullname/
	ncpu=`cat /proc/cpuinfo | grep processor | wc -l`
	make -j$ncpu
	if test -z $no_check   # run the make check, unless $no_check is set for this package definition
	then make -j$ncpu check || make -j$ncpu test
	fi
	make install
	ln -snv $installdirectory/$package_fullname $installdirectory/$package_name || true
	# NOTE: .m4 files should probably be installed as well by default, but i have no strong opinion on it, so for now we leave this to the postinstall() function
	cd ../..
	rm -r $builddir
}
